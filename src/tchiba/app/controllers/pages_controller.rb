class PagesController < ApplicationController
  before_action :check_for_cart, only: [:home] 

  def home
  end

  def contact
  end

  def admindashboard
  end

  def browse
    @pagy, @blends = pagy(Blend.all)
  end

  def search
    redirect_to browse_path if search_params.empty?
    property_ids = get_property_ids
    @pagy, @blends = pagy(search_function(search_params[:search], property_ids))
    
    render 'browse'
  end

private

  def search_params
    params.require(:browse).permit(:search, :tea_ids, :flavour_ids, tea_ids: [], flavour_ids: [])
  end

  def get_property_ids
    property_ids = Array.new
    
    if search_params[:tea_ids].size > 0
      if search_params[:tea_ids].class == String
        property_ids << search_params[:tea_ids].to_i
      else
        search_params[:tea_ids].each{|id| property_ids << id.to_i if id.to_i > 0}
      end 
    end

    if search_params[:flavour_ids].size > 0 
      if search_params[:flavour_ids].class == String
        property_ids << search_params[:flavour_ids].to_i
      else
        search_params[:flavour_ids].each{|id| property_ids << id.to_i if id.to_i > 0}
      end
    end
    return property_ids
  end

  def search_function(search_term, property_ids)
    term = false
    if search_term.length > 0
      blends_relation = Blend.where("blends.name LIKE ?", "%#{search_term}%")
      term = true
      return blends_relation if blends_relation.empty?
    else
      blends_relation = Blend.joins(:properties).where("properties.id = ?", property_ids[0])
      property_ids.shift
      return blends_relation if blends_relation.empty? || property_ids.empty?
    end
    until property_ids.empty?
      if term
        blends_relation = Blend.where("blends.name LIKE ?", "%#{search_term}%").joins(:properties).where("properties.id = ?", property_ids[0])
      else
        blends_relation = Blend.joins(:properties).where("properties.id = ?", property_ids[0])   
      end
      property_ids.shift
      return blends_relation if blends_relation.empty? || property_ids.empty?
    end

    return blends_relation
  end

end
