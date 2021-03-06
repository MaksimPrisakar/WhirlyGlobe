//
//  AnimatedBasemapTestCase.swift
//  AutoTester
//
//  Created by jmnavarro on 26/10/15.
//  Copyright © 2015 mousebird consulting. All rights reserved.
//

import UIKit

class AnimatedBasemapTestCase: MaplyTestCase {

	let geographyClass = GeographyClassTestCase()
	let cacheDir = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0]
	var tileSources = [MaplyRemoteTileInfo]()

	override init() {
		super.init()

		self.name = "Animated basemap"
		self.captureDelay = 2
		self.implementations = [.globe, .map]
	}

	// Collect up the various precipitation sources
	func buildTileSources() {
		for i in 0...4 {
			let precipTileSource = MaplyRemoteTileInfo(
				baseURL: "http://a.tiles.mapbox.com/v3/mousebird.precip-example-layer\(i)/",
				ext: "png",
				minZoom: 0,
				maxZoom: 6)
			precipTileSource.cacheDir = "\(cacheDir)/forecast_io_weather_layer\(i)/"
			tileSources.append(precipTileSource)
		}
	}

	func createLayer(_ baseView: MaplyBaseViewController) -> (MaplyQuadImageTilesLayer) {
		let precipTileSource = MaplyMultiplexTileSource(sources: tileSources)
		// Create a precipitation layer that animates
		let precipLayer = MaplyQuadImageTilesLayer(tileSource: precipTileSource!)
		precipLayer?.imageDepth = UInt32(tileSources.count)
		precipLayer?.animationPeriod = 1.0
		precipLayer?.imageFormat = MaplyQuadImageFormat.imageUByteRed
		precipLayer?.numSimultaneousFetches = 4
		precipLayer?.handleEdges = false
		precipLayer?.coverPoles = false
		precipLayer?.shaderProgramName = WeatherShader.setupWeatherShader(baseView)
		precipLayer?.fade = 0.5
		return precipLayer!
	}
	override func setUpWithGlobe(_ globeVC: WhirlyGlobeViewController) {
		geographyClass.setUpWithGlobe(globeVC)
		buildTileSources()
		globeVC.add(createLayer(globeVC))
	}

	override func setUpWithMap(_ mapVC: MaplyViewController) {
		geographyClass.setUpWithMap(mapVC)
		buildTileSources()
		mapVC.add(createLayer(mapVC))
	}

}
