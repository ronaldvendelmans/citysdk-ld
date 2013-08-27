require "sequel/model"


class Layer < Sequel::Model
  many_to_one :owner
  plugin :validation_helpers

  def validate
    super
    validates_presence [:name, :description, :organization, :category]
    validates_unique :name
    validates_format /^\w+(\.\w+)*$/, :name
    validates_format /^\w+\.\w+$/, :category
    if (import_config.nil? or import_config=='') and import_url != nil
      errors.add(:import_url,"Cannot be set without config. Upload file once, first.")
    end
  end
  
  def fieldDefsSelect() 
  end
  
  
  def self.languageSelect() 
    '<select style="border 0px;" id="relation_lang"> \
      <option value="@ca">català</option> \
      <option value="@de">deutsch</option> \
      <option value="@el">ελληνικά</option> \
      <option value="@en" selected = "selected">english</option> \
      <option value="@es">español</option> \
      <option value="@fr">français</option> \
      <option value="@fy">frysk</option> \
      <option value="@li">limburgs</option> \
      <option value="@nl">nederlands</option> \
      <option value="@pt">português</option> \
      <option value="@fi">suomi</option> \
      <option value="@sv">svenska</option> \
      <option value="@tr">türkçe</option> \
    </select>'  
  end

  def self.propertyTypeSelect() 
    '<select style="border 0px;" id="ptype" onchange="selectFieldType(this.value)"> \
      <option>select...</option> \
      <option>Quantity</option> \
      <option>URI</option> \
      <option>Label/Identifier</option> \
      <option>Date/Time</option>  \
      <option>Descriptive</option> \
    </select>'  
  end
  
  
  
  
  def self.category_select(sel=false, all=false)
    s= all ? 
      "<select name='catprefix' onchange='layerSelect(this)'> " : 
      "<select name='catprefix'> "
    
    s += "<option #{sel=='all' ? 'selected="selected"' : ''}>all</option>" if all
    sel = 'administrative' if sel==false
    
    Category.order(:name).all.each do |c|
      s += "<option #{c.name==sel ? 'selected="selected"' : ''}>#{c.name}</option>"
    end
    s += "</select>"
    s
  end
  
  
  def period_select()
    period  = "<select name='period'> "
    ['never','monthly','weekly','daily','hourly'].each do |p|
      if import_period == p 
        period += "<option selected='selected'>#{p}</option>"
      else
        period += "<option>#{p}</option>"
      end
    end
    period += "</select>"
    period
  end
  
  
  def cat_select
    self.category = '.' if self.category.nil?
    pref = self.category.split('.')[0]
    categories = Layer.category_select(pref)
    self.category = self.category.split('.')[1]
    return categories
  end
  
  
  def self.selectTag 
    r = "<select>"
    Layer.order(:id).all do |l|
      r += "<option>#{l.name}</option>"
    end
    r += "</select>"

  end
  
  
  
end
