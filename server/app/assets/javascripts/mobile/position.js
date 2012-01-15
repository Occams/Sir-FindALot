var Position = {
	longitude : null,
	latitude : null,
	RADIUS : 6371, // km
	
	distance : function (lon2, lat2) {
		if (this.longitude != null && this.latitude != null) {
			var lat1 = this._toRad(this.latitude), lon1 = this._toRad(this.longitude);
			var lat2 =  this._toRad(lat2), lon2 =  this._toRad(lon2);
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
	},
	
	_toRad : function (deg) {
		return deg * Math.PI / 180;
	}
	
};
