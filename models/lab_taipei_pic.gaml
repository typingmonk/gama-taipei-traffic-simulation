/**
* Name: labtaipei
* Author: TMonk, 小傅
* Description: 
* Tags: Tag1, Tag2, TagN
*/

model labtaipei

/* Insert your model definition here */

global{
	//file buildings_shapefile <- file("../includes/building.osm");
	file roads_shapefile <- file("../includes/road_bigtaipei.osm");
	geometry shape <- envelope(roads_shapefile);
	graph road_network <- roads_shapefile;
	int nm_car <- 100;
	string car_green const: true <- '../images/green_car.png' ;
	string car_red const: true <- '../images/red_car.png'  ;
	init {
		//create building from: buildings_shapefile ;
		create road from: roads_shapefile ;
//		create background;
		create station number: 80{
			location <- any_location_in (one_of(road));
		}
		create people number: nm_car{
			location <- any_location_in (one_of(road));
			target <- any_location_in (one_of(road));
			max_level <- 250; 
			ctrl_level <- 100;
			level <- ctrl_level + rnd(max_level-ctrl_level);
			
			
			speed <- 20.0;
		}
		road_network <- as_edge_graph(road);
	}
}

species road {
	rgb color;
	aspect base {
		draw shape color: #black;
	}
}

species building {
	rgb color;
	aspect base {
		draw shape color: #grey;
	}
}

species station {
	rgb color;	
	aspect base {
		draw square(100) color: #blue;
	}
}

species people skills:[moving]{
	int level;
	int ctrl_level ;
	int max_level ;
	point target; 
	point record;
	bool status;
	rgb color; //<- rgb(0,255,0);
	aspect base {
		draw circle(100) color:color;
	}
	
	aspect pic {
		if(level>ctrl_level){
			draw file(car_green) rotate: heading at: location size: {300,300};
		}else{
			draw file(car_red) rotate: heading at: location  size: {300,300};
		}
	}
	
	reflex move  {
		if(level>0){
			level<-level-1;		
		}
		
		color <- rgb(255*(1-(level/max_level)),255*(level/max_level),0);
		
		if(location = record){
			target <- any_location_in (one_of(road));
		}
		record <- location;
		
		
		if(level>ctrl_level){
			status <- true;
			write "level" +level;
			do goto target: target on: road_network recompute_path: true;
			if(location = target){
			  target <- any_location_in (one_of(road));
			}
			//color <- #green;
		}
		else if(0<level and level<=ctrl_level){
			status <- true;
			//color <- #red;
			target <- (station closest_to location).location;
			do goto target: target on: road_network recompute_path: true;
			if(target = location){
				level <- max_level;
			}
		}else{
			status <- false;
			//color <- #black;
			write "dead";
			
		}
	}
	
	
}

//species background{
//	aspect base{
//		write world.shape.width;
//		draw image_file('../images/a5-3-1_crop.png') at: {0,0} ; // size:{1300,800}
//	}
//}


experiment traffic{
	output {
		display city_display type: opengl{
			//species building aspect: base; 
			image '../images/bigtaipei_light.png' refresh: false;
//			species background aspect: base;
			species road aspect:base;
			species people aspect:base;
			species station aspect:base;
		}
		display my_chart {
			chart "0 power cars" {
				data "0 power" value: length (people where (each.status = false));
			}
		}
	}
}
