setup_mergetool() {
	# Set Neovim as the default merge tool
	git config --global merge.tool nvimdiff

	# (Optional) Set Neovim as the default diff tool for 'git difftool'
	git config --global diff.tool nvimdiff

	# (Optional) Stop Git from prompting "Hit return to launch..." every time
	git config --global difftool.prompt false
	git config --global mergetool.prompt false

}
