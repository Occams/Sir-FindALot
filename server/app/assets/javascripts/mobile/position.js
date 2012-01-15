if (typeof(Number.prototype.toRad) === "undefined") {
	Number.prototype.toRad = function () {
		return this * Math.PI / 180;
	}
}

var Position = {
	longitude : null,
	latitude : null,
	RADIUS : 6371, // km
	
	distance : function (lon, lat) {
		if (this.longitude != null && this.latitude != null) {
			var lat1 = this.latitude.toRad(),
			lon1 = this.longitude.toRad();
			var lat2 = lat.toRad(),
			lon2 = lon.toRad();
			var dLat = lat2 - lat1;
			var dLon = lon2 - lon1;
			
			var a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
				Math.cos(lat1) * Math.cos(lat2) *
				Math.sin(dLon / 2) * Math.sin(dLon / 2);
			var c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
			return this.RADIUS * c;
		} else {
			return null;
		}
	}
	
};
