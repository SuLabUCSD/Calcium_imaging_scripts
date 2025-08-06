macro "Full_AutoMoco [q]" {
path=getDir("Choose a Directory");
Fly_list=getFileList(path);

for (a = 0; a < Fly_list.length; a++) {
	current=path+Fly_list[a];
	Dilu_folder=getFileList(current);
	print(Fly_list[a]);
	if (endsWith(Dilu_folder[0], "/")) {
		for (i = 0; i < Dilu_folder.length; i++) {
			temp1=current+Dilu_folder[i];
			open(temp1);
			filename=getTitle();
			selectWindow(filename);
			run("Z Project...", "start=60 stop=60 projection=[Max Intensity]");
			run("moco ", "value=5 downsample_value=2 template="+"MAX_"+filename+" "+"stack="+filename+" "+"log=None plot=[No plot]");
			savedname="New_moco.tif";
			saveAs("tiff", temp1+savedname);
		}
	}
	close("*");
}
}
