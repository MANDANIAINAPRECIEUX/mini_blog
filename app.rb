require 'sinatra'
require 'json'
require 'securerandom'

enable :method_override

ARTICLES_FILE = File.join(File.dirname(__FILE__), 'articles.json')
IMAGES_FILE = File.join(File.dirname(__FILE__), 'images.json')

def read_articles
  JSON.parse(File.read(ARTICLES_FILE))
rescue
  []
end

def write_articles(articles)
  File.write(ARTICLES_FILE, JSON.pretty_generate(articles))
end

# Page Qui suis-je
get '/' do
  erb :index
end

# Page Mes articles
get '/articles' do
  @articles = read_articles
  erb :articles
end



# ⚡ Route pour le formulaire /new
get '/new' do
  erb :new
end

# Route pour créer l'article
post '/create' do
  articles = read_articles

  new_article = {
    "id" => SecureRandom.uuid,
    "title" => params["title"],
    "content" => params["content"],
    "date" => Time.now.strftime("%d/%m/%Y")
  }

  articles << new_article
  write_articles(articles)

  redirect '/articles'
end


# Route pour afficher le formulaire de modification
get '/edit/:id' do
  @articles = read_articles
  @article = @articles.find { |a| a["id"] == params[:id] }

  if @article
    erb :edit
  else
    "Article non trouvé"
  end
end


# Route pour mettre à jour un article
post '/update/:id' do
  articles = read_articles
  article = articles.find { |a| a["id"] == params[:id] }

  if article
    article["title"] = params["title"]
    article["content"] = params["content"]
    write_articles(articles)
    redirect '/articles'
  else
    "Article non trouvé"
  end
end


# Route pour supprimer un article
get '/delete/:id' do
  articles = read_articles
  articles.reject! { |a| a["id"] == params[:id] }
  write_articles(articles)
  redirect '/articles'
end




# Helpers pour les images
def read_images
  JSON.parse(File.read(IMAGES_FILE))
rescue
  []
end

def write_images(images)
  File.write(IMAGES_FILE, JSON.pretty_generate(images))
end

# Page liste des images
get '/images' do
  @images = read_images
  erb :images
end

# Formulaire pour ajouter une nouvelle image
get '/images/new' do
  erb :new_image
end

# Créer une image
post '/images/create' do
  images = read_images
  image_path = nil

  # 1) Si un fichier local est uploadé
  if params["file"] && params["file"][:tempfile]
    filename = "#{SecureRandom.uuid}_#{params["file"][:filename]}"
    filepath = "./public/uploads/#{filename}"

    File.open(filepath, "wb") do |f|
      f.write(params["file"][:tempfile].read)
    end

    image_path = "/uploads/#{filename}"
  end

  # 2) Si une URL a été fournie
  if params["url"] && params["url"] != ""
    image_path = params["url"]
  end

  # 3) Vérification : doit avoir au moins un fichier ou une URL
  if image_path.nil?
    return "Veuillez choisir un fichier ou entrer une URL."
  end

  new_image = {
    "id" => SecureRandom.uuid,
    "title" => params["title"],
    "description" => params["description"],
    "url" => image_path,
    "date" => Time.now.strftime("%d/%m/%Y")
  }

  images << new_image
  write_images(images)

  redirect '/images'
end



# Modifier une image
get '/images/edit/:id' do
  @images = read_images
  @image = @images.find { |i| i["id"] == params[:id] }
  if @image
    erb :edit_image
  else
    "Image non trouvée"
  end
end

post '/images/update/:id' do
  images = read_images
  image = images.find { |i| i["id"] == params[:id] }

  if image
    image["title"] = params["title"]
    image["url"] = params["url"]
    image["description"] = params["description"]
    write_images(images)
    redirect '/images'
  else
    "Image non trouvée"
  end
end

# Supprimer une image
get '/images/delete/:id' do
  images = read_images
  images.reject! { |i| i["id"] == params[:id] }
  write_images(images)
  redirect '/images'
end

