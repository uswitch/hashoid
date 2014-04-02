require_relative 'hashoid/version'
require 'active_support/inflector'

module Hashoid

  def self.included base
    base.extend(ClassMethods)
  end

  module ClassMethods

    def field name, opts={}
      _fields[name] = opts.dup
      attr_reader name
    end

    def fields names, opts={}
      names.each{|name| field(name, opts)}
    end

    def collection name, opts={}
      field(name, opts.merge(collection: true))
    end

    def collections names, opts={}
      names.each{|name| collection(name, opts)}
    end

    def from_json(json)
      self.new(JSON.parse(json))
    end
    
    def _fields
      @fields ||= superclass.respond_to?(:_fields) ? {}.merge(superclass._fields) : {}
    end

    def is_collection? field
      _fields[field] && _fields[field][:collection]
    end

    def field_names
      _fields.keys
    end

    def field_type(field, &block)
      info = _fields[field] ||= {}
      info[:checked], info[:type] = true, yield unless info[:type] or info[:checked]
      info[:type]
    end

    def field_default field
      _fields[field] && _fields[field][:default]
    end

    def field_transform field
      _fields[field] && _fields[field][:transform]
    end

    def find_class field
      field_type(field) do
        class_name = field.to_s.split('_').map(&:capitalize).join
        class_name = class_name.singularize if is_collection?(field)
        my_module.const_get(class_name) if my_module.const_defined?(class_name)
      end
    end

    def alias_boolean field
      alias_method("#{field}?", field) 
    end
  
    def my_module
      @my_module ||= (self.name =~ /^(.+)::[^:]+$/) ? $1.constantize : Module
    end
  end
  
  def initialize args={}
    self.class._fields.each {|k, _| instance_variable_set("@#{k}", self.class.field_default(k))}

    @args = args
    args.each do |k, v|
      field = k.to_s.gsub('-', '_').to_sym
      unless defined?(field).nil? # check if it's included as a reader attribute
        result = v.instance_of?(Array) ? init_objects(field, v) : init_object(field, v)
        instance_variable_set("@#{field}", result)
        self.class.alias_boolean(field) if !!result == result # convenience field? method for boolean values
      end
    end
  end

  def each
    self.class.field_names.map do |f| 
      [f, self.send(f)]
    end.reject do |_, v| 
      v.nil?
    end.each do |f, v| 
      yield(f, v)
    end 
  end

  def [] field
    respond_to?(field) ? self.send(field) : @args[field]
  end

  def to_h
    @args
  end

  def to_json
    to_h.to_json
  end

  private

  def init_objects field, values
    values.inject([]) {|arr, v| arr << init_object(field, v)}
  end
  
  def init_object field, value 
    klass = self.class.find_class(field)
    value.instance_of?(Hash) && klass ? klass.new(value) : transform(field, value)
  end

  def transform field, value
    (value && self.class.field_transform(field)) ? self.class.field_transform(field).call(value) : value
  end
    
end

