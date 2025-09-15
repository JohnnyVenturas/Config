target_dir=~/.config/nvim
if [ ! -d "$target_dir" ] ; then
	mkdir -p ~/.config/nvim
fi


#persist the folder 
cp  *.lua "$target_dir"

cp -r lua "$target_dir"

cp install.sh "$target_dir"

#setup git folder for future use 
[ -f "$target_dir"/.gitignore ] && rm "$target_dir"/.gitignore ; cp .gitignore "$target_dir"

[ -d "$target_dir"/.git ]  && rm -rf "$target_dir"/.git ; cp .git "$target_dir"




