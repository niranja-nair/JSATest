/********************************************

   HTML ELEMENTS

********************************************/ 

/* Top Elements */

* {

	margin: 0;

	padding: 0;

}

/*table {

	background-color: #ffffff;

}*/




.float-right a {

	display:inline;

	text-decoration:underline;

}

#border {

	border-bottom: 2px solid #003e7e;

	margin-top:30px;

	margin-bottom:25px;

}

#border h4 {

	border-bottom:none;

	display:inline;

}

/*  */

img {

	border: 0px;

}

img.float-right {

	margin: 5px 0px 10px 10px;

}

img.float-left {

	margin: 5px 10px 10px 0px;

}


code {

	margin: 5px 0;

	padding: 10px;

	text-align: left;

	display: block;

	overflow: auto;

	font: 500 1em/ 1.5em 'Lucida Console', 'courier new', monospace;

	/* white-space: pre; */

	background: #FAFAFA;

	border: 1px solid #f2f2f2;

}

acronym {

	cursor: help;

	border-bottom: 1px solid #777;

}

blockquote {

	margin: 10px;

	padding: 0 0 0 28px;

	border: 1px solid #f2f2f2;

	background: #FAFAFA url(../images/quote.gif) no-repeat 5px 5px;

}

/* form elements */

form {




}
p.post-date {
    background: none repeat scroll 0 0 #FFFFFF;
    border: 1px solid #FFFFFF;
    display: block;
    float: left;
    height: 38px;
    line-height: 100%;
    margin: 0;
    padding: 0;
    position: relative;
    text-align: center;
    width: 38px;
}
.rightSide {
    float: left;
    margin: 0;
    padding: 0;
	width:525px;
	margin-left:5px;
}
.post-date span.month {
    background: none repeat scroll 0 0 #0C4384;
    border-bottom: 1px solid #FFFFFF;
    color: #FFFFFF;
    font-size: 85%;
    left: 0;
    padding: 2px 0;
    position: absolute;
    text-transform: uppercase;
    top: 0;
    width: 100%;
}
.post-date span.day {
    bottom: 1px;
    left: 0;
    padding: 3px 0;
    position: absolute;
    width: 100%;
}
label {

    padding: 0px 15px 0px 3px;

	margin: 5px 0;

}

input {

	background-color: #e4e4e4;

	padding: 2px;

	border: 1px solid #003e7e;

	font:Arial, Helvetica, sans-serif normal 1em;

	color: #333;

}

select {

	border: 1px solid #003e7e;

	color: #333333;

	background-color:#e4e4e4;

}

textarea {

	/*background-color: #d2d9ff;*/

	width: 400px;

	padding: 2px;

	font: normal 1em Verdana, sans-serif;

	border: 1px solid #CCC;

	height: 100px;

	display: block;

	color: #777;

}

input.button {

	margin: 0;

	padding: 2px 3px;

	background: #FFF;

	color: #4F82CB;

	border:none;

	width:55px;

	height:20px;

	background-image:url(../images/blue-button-small.png);

	color:#fff;

	font-size:11px;

	cursor:pointer;

	font-stretch:normal;

}

/*input.button:hover {

	background: url('../images/bg_nav.gif') #ffffff;

	color: white;

}*/



input.button2, .ditch-next-tab-button, .ditch-prev-tab-button {

	margin: 0;

	font: 12pt Arial, Sans-serif;

	border: 1px solid #000;

	padding: 2px 3px;

	background: #FFF;

	color: #003e7e;

	cursor:pointer;

}

input.button2:hover, .ditch-next-tab-button:hover, .ditch-prev-tab-button:hover {

	background: url('../images/bg_nav.gif') #ffffff;

	color: white;

}

input.sav_reg {

	border:none;

	width:116px;

	height:31px;

	background:url('../images/sav_reg.png') no-repeat;

}

input.sav_reg:hover {

	background-position:0px -31px;

	cursor:pointer;

}

input.sav_fin {

	border:none;

	width:79px;

	height:28px;

	background:url('../images/sav_fin.png') no-repeat;

}

input.sav_fin:hover {

	background-position:0px -28px;

	cursor:pointer;

}

/* search */

form.search {

	position: absolute;

	top: 35px;

	right: 25px;

	background: transparent;

	border: none;

}

form.search input.textbox {

	margin: 0;

	padding: 1px 2px;

	width: 120px;

	background: #FFF;

	color: #333;

}

form.search input.button {

	background: #CCC url(../images/headerbg.gif) repeat-x;


	color: #333;

	border: none;

	width: 70px;

	height: 21px;

}

.loginbutton {

	margin-top:15px;

	padding:0;

	border:none;

	width:55px;

	height:20px;

	background-image:url(../images/blue-button-small.png);

	color:#fff;

	font-size:11px;

	cursor:pointer;

}

.big-red-button {

	float:right;

	margin-top:15px;

	width:100px;

	height:32px;

}

.big-red-button input {

	width:100px;

	height:32px;

	background:none;

	border:none;

	color:#fff;

	padding:0;

	font-size:22px;

	cursor:pointer;

}

.big-red-button a {

	width:100px;

	height:32px;

	border:none;

	background:none;

}

a.no_underline:hover {

	text-decoration:none;

}

/********************************************

   LAYOUT

********************************************/

#scroll {

	width: 95%;

	height: 300px;

	overflow: scroll;

}

#scroll2 {

	width: 400px;

	height: 200px;

	overflow: scroll;

}

#wrap {

	width: 820px;

	background: #CCC url(../images/content.jpg) repeat-y center top;

	margin: 0 auto;

	text-align: left;

}

#content-wrap {

	clear: both;

	width: 850px;

	padding: 0;

	margin: 20px auto 0;

}

#header {

	
	position: relative;

	

	padding: 0;

	font-size: 14pt;

	color: #FFF;

}
#columns{
	width:930px;
	float:left;
}
#header h1#logo-text {

	position: absolute;

	margin: 0;

	padding: 0;

	font: bolder 2.5em 'Trebuchet MS', Arial, Sans-serif;

	letter-spacing: -2px;

	/*color: #FFF;*/

	text-transform: none;

	/* change the values of top and left to adjust the position of the logo*/

	top: 40px;

	left: 50px;

}

#header h2#slogan {

	position: absolute;

	margin: 0;

	padding: 0;

	font: normal .8em 'Trebuchet MS', Arial, Sans-serif;

	text-transform: none;

	color: #FFF;

	/* change the values of top and left to adjust the position of the slogan*/

	top: 66px;

	left: 58px;

}

#flash {

	padding-top:25px;
	padding-left:75px;

	float:left;

}

.login {
	float:right;
	width:307px;
	padding-right:75px;
	padding-top:25px;
}

.login h2 {

	color:#9a0100;

	font-size:24px;

	margin-left:30px;

	font-stretch:semi-condensed;

	text-transform:none;

	font-weight:normal;

	font-family:Arial, Helvetica, sans-serif;

	padding:15px 0 10px 0;

}

.large-red-text {

	font-size:24px;

	font-stretch:semi-condensed;

	font-weight:bold;

	line-height:26px;

	margin-top:25px;

	color:#9a0100;

	padding:0;

}

.large-blue-text {

	font-size:20px;

	font-stretch:semi-condensed;

	line-height:26px;

	color:#003e7e;

	padding:0;

}

/* Menu */

#menu {

	clear: both;

	margin: 0;

	/*padding: 0 40px 0 0;*/

	background: url('../images/bg_nav.gif') #ffffff;

	font: bold 12pt/ 26pt Verdana, Arial, Tahoma, Sans-serif;

	height: 26px;

	margin-left: auto;

	margin-right: auto;

	width: 874px;

}

#menu ul {

	float: right;

	list-style: none;

	margin: 0;

	padding: 0;

}

#menu ul li {

	display: inline;

}

#menu ul li a {

	display: block;

	float: left;

	padding: 0 8px;

	color: #FFF;

	text-decoration: none;

}

#menu ul li a:hover {

	background-color: #ECECEC;

	color: #333;

}

#menu ul li#current a {

	background-color: #FFF;

	color: #333;

}

/* Main Column */

#main {

	float: right;

	width: 70%;

	padding: 0;

	margin: 0;

}

#main2 { /*float: center;*/

	width: 60%;

	padding: 0;

	margin: 0;

}

#main h1 {

	margin-top: 10px;

	font: Bold 125% Verdana, 'Trebuchet MS', Sans-serif;

	color: #88ac0b;

	padding: 5px 0 5px 25px;

	border-bottom: 1px solid #EFF0F1;

	background: #FFF url(../images/square-green.png) no-repeat 3px 50%;

}

.post-footer {

	background-color: #FAFAFA;

	padding: 5px;

	margin: 20px 10px 0 10px;

	border: 1px solid #f2f2f2;

	font-size: 95%;

}

.post-footer .date {

	background: url(../images/clock.gif) no-repeat left center;

	padding-left: 20px;

	margin: 0 10px 0 5px;

}

.post-footer .comments {

	background: url(../images/comment.gif) no-repeat left center;

	padding-left: 20px;

	margin: 0 10px 0 5px;

}

.post-footer .readmore {

	background: url(../images/page.gif) no-repeat left center;

	padding-left: 20px;

	margin: 0 10px 0 5px;

}

.errorMessage {

	color:#003e7e;

	font-weight:bold;

	padding:8px 10px;

	background-color:#f79779;

	border:solid 1px #ae0c1b;

}

/* Sidebar */

#sidebar {

	border-top: 1px solid #537ba4;

	border-right: 1px solid #537ba4;

	border-left: 1px solid #537ba4;

	background-color:#e4e4e4;

	float: left;

	width: 25%;

	padding: 0;

	margin: 93px 0 0 20px;

}

#sidebar h1 {

	margin-top: 0px;

	padding: 10px 0 5px 4px;

	color: #9a0100;

}

#sidebar .left-box {

	padding-bottom:10px;

	border-bottom:1px solid #003e7e;

}

#sidebar ul.sidemenu {

	list-style: none;

	margin: 0;

	padding: 0;

	text-decoration: none;

}

#sidebar ul.sidemenu2 {

	list-style: none;

	text-align: left;

	margin: 3px 0 8px 0;

	padding: 0;

	text-decoration: none;

	height: 100px;

	overflow: scroll;

}

#sidebar ul.sidemenu2 li {

	border-bottom: 1px solid #EFF0F1;

	background: url(../images/go.gif) no-repeat 5px 5px;

	padding: 2px 0 2px 25px;

	margin: 0 2px;

}

#sidebar ul.sidemenu2 a {

	font-weight: bolder;

	text-decoration: none;

	background-image: none;

}

#sidebar ul.sidemenu li {

	padding: 2px 0 2px 25px;

	margin: 0 2px;

}

#sidebar ul.sidemenu a {

	color:#333;

	text-decoration: none;

	background-image: none;

}

#sidebar ul.sidemenu a:hover {

	color:#003e7e;

	font-weight:bold;

}

/* Sidebar right */

#sidebarScroll {

	float: right;

	width: 30%;

	padding: 0;

	margin: 0;

}

#sidebarScroll h1 {

	margin-top: 10px;

	padding: 5px 0 5px 10px;

	font: bold 1.1em Verdana, 'Trebuchet MS', Sans-serif;

	color: #555;

	background: #EEF0F1 url(../images/headerbg.gif) repeat-x left bottom;

	border: 1px solid #EFF0F1;

}

#sidebarScroll .left-box {

	border: 1px solid #EFF0F1;

	margin: 0 0 5px 0;

}

#sidebarScroll ul.sidemenu {

	list-style: none;

	text-align: left;

	margin: 3px 0 8px 0;

	padding: 0;

	text-decoration: none;

}

#sidebarScroll ul.sidemenu li {

	border-bottom: 1px solid #EFF0F1;

	background: url(../images/go.gif) no-repeat 5px 5px;

	padding: 2px 0 2px 25px;

	margin: 0 2px;

}

#sidebarScroll ul.sidemenu a {

	font-weight: bolder;

	text-decoration: none;

	background-image: none;

}

/* alignment classes */

.float-left {

	float: left;

}

.float-right {

	float: right;

}

.align-left {

	text-align: left;

}

.align-right {

	text-align: right;

}

/* display and additional classes */

.clear {

	clear: both;

}

.gray {

	color: #CCC;

}

.black {

	color: black;

}

.red {

	color: red;

	font-style: italic;

}

a.red-link-small {

	color:#9a0100;

	font-size:12px;

}

.tunnelFormTableHome {

	border: solid 0px;

	border-color: #005eb6;

	width: 100%;

	color: #005eb6;

	/*background: white;*/

	margin-bottom: 20px;

	padding-bottom: 9px;

	padding-right: 9px;

	/*border-bottom: 1px solid #F2F2F2;*/

	letter-spacing: -0.035em;

	font-weight: normal;

	color: #666666;

	font-size: 12pt;

}

.tunnelFormTableHome th {

	background: url('../images/header_bg_60.gif');

	font-size: 14pt;

	color: #666666;

	height: 25px;

	text-align: left;

	font-weight: normal;

}

.tunnelFormTableHome tr td {

	margin: 0;

	padding: 5px 5px 5px 5px;

}

.tunnelFormTableMini {

	width: 100%;

	table-layout: auto;

	margin-bottom: 20px;

	padding-bottom: 9px;

	border-bottom: 1px solid #003e7e;

	letter-spacing: -0.035em;

	font-weight: normal;

	color: #333;

}

.bottom {

	border-bottom:none;

}

.title_margin { 

	margin-bottom:37px; 

}

.tunnelFormTableMini th {

	font-size: 12pt;

	/*color: #005eb6;*/

	height: 15px;

	text-align: left;

	font-weight: normal;

}

.tunnelFormTableMini tr td {

	margin: 0;

	font-size: 14px;

	padding: 5px 5px 5px 5px;

	height: 18px;

	width: auto;

	letter-spacing:normal;

}

.tunnelFormTableMini textarea {

	padding: 2px;

	font: normal 1em Verdana, sans-serif;

	border: 1px solid #003e7e;

	display: block;

	color: #333333;

	background-color:#e4e4e4;

}

.tunnelFormTableMini a, .tunnelFormTableMini a:visited {

	text-decoration: none;

	color: #003e7e;

	background: inherit;

}

.tunnelFormTableMini a:hover {

	text-decoration:underline;

	background: inherit;

}

sortable {

	border: solid 0px;

	border-color: #005eb6;

	width: 100%;

	table-layout: auto;

	color: #005eb6;

	margin-bottom: 20px;

	padding-bottom: 9px;

	border-bottom: 1px solid #F2F2F2;

	/*border-top: 1px solid #F2F2F2;*/

	letter-spacing: -0.035em;

	font-weight: normal;

	color: #37404C;

}

.sortable th {

	font-size: 14px;

	text-align: left;

	font-weight: bold;

	padding-bottom:5px;

}

.sortable tr td {

	margin: 0;

	font-size: 9pt;

	padding: 5px 5px 5px 5px;

	height: 11px;

	width: auto;

}

.tunnelFormTableMedium {

	border: solid 0px;

	border-color: #005eb6;

	width: 100%;

	table-layout: auto;

	/*color: #005eb6;*/

	/*margin-bottom: 20px;*/

	padding-bottom: 9px;

	/*border-bottom: 1px solid #F2F2F2;*/

	/*border-top: 1px solid #F2F2F2;*/

	/*letter-spacing: -0.035em;*/

	font-weight: normal;/*color: #37404C;*/

}

.tunnelFormTableMedium th {

	background: url('../images/header_bg_60.gif');

	font-size: 13pt;

	/*color: #005eb6;*/

	height: 14px;

	text-align: left;

	font-weight: normal;

}

.tunnelFormTableMedium tr td {

	margin: 0;

	/*font-size: 11pt;*/

	padding: 5px 5px 5px 5px;

	/*height: 11px;*/

	width: auto;

}

.page_saveChanges {

	padding: 5px;

	background: transparent url('../images/bg.savecontainer.fade.gif');

}

.tunnelTableSuggest {

	border: solid 0px;

	border-color: #005eb6;

	width: 100%;

	table-layout: auto;

	color: #005eb6;

	margin-bottom: 0px;

	padding-bottom: 1px;

	padding-top: 1px;

	border-bottom: 2px solid #F2F2F2;

	/*border-top: 1px solid #F2F2F2;*/

	letter-spacing: -0.035em;

	font-weight: normal;

	color: #37404C;

}

.tunnelTableSuggest th {

	background: url('../images/header_bg_60.gif');

	font-size: 12pt;

	/*color: #005eb6;*/

	height: 13px;

	text-align: left;

	font-weight: normal;

	padding-bottom: 2px;

}

.tunnelTableSuggest tr td {

	margin: 0;

	font-size: 9pt;

	padding: 0px 0px 0px 0px;

	height: 11px;

	width: auto;

}

.complete {

	font-size:12px;

	color:#00a651;

}

.incomplete {

	font-size:12px;

	color:#ae0c1b;

}

#chapterAction a {

	color:#003E7E;

}

/*.wwctrl {

	margin-top:5px;

}*/

.ditch-tab-skin-default td a {

color:#003e7e;

}

/*\*/

html>body* .bodycell {

	background-color: #FFFFFF;

}

/**/

.noborder { border:none; font-weight:bold; width:85px; }

#archivebox{
	overflow:hidden;	
}
#archivebox h2{
	float:left;	
}
#archivebox .helpLink{
	float:right;
}