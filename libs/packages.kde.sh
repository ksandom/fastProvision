# This file contains packages KDE.

packagesKDE="kde-standard"


function chrootKDETasksel
{
	chrootRun aptitude install -y ~t^desktop$ ~t^kde-desktop$	
}

