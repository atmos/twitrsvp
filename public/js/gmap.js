function createMarker(point,html,mapicon, link_title) {
  var marker = new GMarker(point, {icon: mapicon, title: link_title});
  GEvent.addListener(marker, "click", function() {
    marker.openInfoWindowHtml(html);   
  });
  return marker;
}
function build_icon(){
	var icon = new GIcon(G_DEFAULT_ICON);
  icon.image =  '/img/mapicon.png';
  icon.iconSize = new GSize(30,39);
  icon.infoWindowAnchor = new GPoint(30, 15);
  return icon;
}

