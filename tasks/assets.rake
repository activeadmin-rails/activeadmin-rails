namespace :assets do
  desc "Compile CSS from SCSS source files"
  task :compile_css do
    system "npm run build:css"
  end

  desc "Compile all assets (JS and CSS)"
  task compile: [:compile_css] do
    system "npm run build"
  end
end
