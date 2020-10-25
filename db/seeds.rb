# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
require 'json'
require 'open-uri'

puts 'Cleaning Database :'

puts 'Delete all doses'
Dose.destroy_all

puts 'Delete all ingredients'
Ingredient.destroy_all

puts 'Delete all cocktails photos from cloudinary'
Cocktail.all.each do |cocktail|
  cocktail.photo.purge if cocktail.photo.attached?
end

puts 'Delete all cocktails'
Cocktail.destroy_all

url = 'https://www.thecocktaildb.com/api/json/v1/1/list.php?i=list'
ingredients = JSON.parse(open(url).read)["drinks"]

puts 'Creating new ingredients'
ingredients.each do |ingredient|
  new_ingredient = Ingredient.create(name: ingredient['strIngredient1'])
end

puts 'Creating new cocktails'

("a".."t").each do |letter|
  url = "https://www.thecocktaildb.com/api/json/v1/1/search.php?f=#{letter}"
  drinks = JSON.parse(open(url).read)["drinks"]

  drinks.each do |drink|
    file = URI.open(drink["strDrinkThumb"])
    @cocktail = Cocktail.new(name: drink["strDrink"], description: drink["strInstructions"])
    @cocktail.photo.attach(io: file, filename: 'cocktail.jpg')
    @cocktail.save
    p @cocktail.valid?

    i = 1
    ingredients = []
    measures = []

    until drink["strIngredient#{i}"].nil? || drink["strIngredient#{i}"] == ""
      ingredients << drink["strIngredient#{i}"]
      measures << drink["strMeasure#{i}"]
      i += 1
    end

    ingredients.each_with_index do |ingredient, index|
      if measures[index].nil?
        dose = Dose.new(description: "unspecified")
      else
        dose = Dose.new(description: measures[index])
      end
      if Ingredient.find_by(name: ingredient).nil?
        dose.ingredient = Ingredient.create(name: ingredient)
      else
        dose.ingredient = Ingredient.find_by(name: ingredient)
      end
      dose.cocktail = @cocktail
      dose.save
    end
  end
end

puts 'Success !!'

