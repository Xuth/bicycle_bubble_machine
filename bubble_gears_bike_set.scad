
// this is publicDomainGearV1.1.scad from https://www.thingiverse.com/thing:5505
use <../lib/gears/gears.scad>;

// this is struct.scad from https://github.com/Xuth/projectbox
use <../lib/struct.scad>

pressureAngle = 20;
mmTooth=6;
pi = 3.141592654;
boltR = 3.175;
openBoltR = 3.75;
m3R = 1.5;
m3TapR = 1.25;
pvc10R = 1.315 * 25.4 / 2;  // 1 inch nominal pvc radius
armTeeth = 36;
mTeeth = 9;
baseTeeth = 135;
lazySusanInnerR = 70.0;
lazySusanOuterR = 101.0;
lazySusanOuterRingW = 14.25;
lazySusanInnerRingW = 13.75;
baseMotorOffset = pitch_radius(mmTooth, baseTeeth) + pitch_radius(mmTooth, mTeeth);
armBoltSpace = 2.5 * 25.4;

innerTowerHOff = 3 * 25.4 / 2;
innerTowerWOff = (3.5 + 1.5) * 25.4 / 2;
TowerThick = 1.5 * 25.4;

buttonR = 5.9;
botButtonR = 17;

$fn = 64;

nema_17 = [
    ["faceWidth", 42.2],
    ["faceHeight", 42.2],
    ["faceCircleR", 11],
    ["boltOffsetX", 15.5],
    ["boltOffsetY", 15.5],
    ["shaftR", 2.5],
    ["shaftFlat", 2.0]
    ];


module lazySusan() {
    difference() {
	circle(r=lazySusanOuterR);
	difference() {
	    circle(r=lazySusanOuterR - lazySusanOuterRingW);
	    circle(r=lazySusanInnerR + lazySusanInnerRingW);
	}
	circle(r=lazySusanInnerR);
    }
}

module lazySusanShadow() {
    %lazySusan();
}


module tower() {
    difference() {
	translate([-innerTowerWOff - TowerThick, -innerTowerHOff - TowerThick])
	    square([(innerTowerWOff + TowerThick) * 2, (innerTowerHOff + TowerThick) * 2]);
	translate([-innerTowerWOff, -innerTowerHOff])
	    square([innerTowerWOff * 2, innerTowerHOff * 2]);
    }
}

module towerShadow() {
    %tower();

}


function coverHoles(fh, fw, extra) =
    concat([ for (x = [-fw/2, 0, fw/2]) [x, -fh/2 - 10]],
	   [for (y = [-fh/2, 0, fh/2]) [-fw/2-10, y]],
	   [for (y = [-fh/2, 0, fh/2]) [fw/2+10, y]]);
								    

module baseGear() {
    hiddenTeeth = 0;
    lazySusanShadow();

    difference() {
	union() {
	    projection() {
		rotate([0,0,hiddenTeeth/baseTeeth*180])
		    gear(mmTooth, baseTeeth, teeth_to_hide=hiddenTeeth, pressure_angle=pressureAngle);
	    }

	    //circle(r=gearInnerRadius(mmTooth, baseTeeth));
	}

	//circle(r=lazySusanInnerR);
	circle(r=pvc10R);
	for (deg = [0:60:359]) {
	    rotate([0,0,deg]) {
		translate([0, pvc10R + 30])
		    circle(r=20);
	    }
	}
	for (deg = [10:20:359]) {
	    rotate([0,0,deg]) {
		translate([0, lazySusanOuterR + 5])
		    circle(r=15);
	    }
	}
	// bolt hole spacing isn't perfectly square!!!
	translate([-55, -55]) circle(r=openBoltR);
	translate([ 55, -55]) circle(r=openBoltR);
	translate([-54,  55]) circle(r=openBoltR);
	translate([ 54,  55]) circle(r=openBoltR);
    }
}

module underBaseGear() {
    lazySusanShadow();

    difference() {
	circle(r=outer_radius(mmTooth, baseTeeth)+2);
	
	circle(r=lazySusanInnerR);
	for (deg = [10:20:359]) {
	    rotate([0,0,deg]) {
		translate([0, lazySusanOuterR + 5])
		    circle(r=15);
	    }
	}
	
	// bolt hole spacing isn't perfectly square!!!
	translate([-55, -55]) circle(r=openBoltR);
	translate([ 55, -55]) circle(r=openBoltR);
	translate([-54,  55]) circle(r=openBoltR);
	translate([ 54,  55]) circle(r=openBoltR);
	
    }


}

module upperBracketBoltHoles() {
    // relative to the motor center

    translate([-48, 10])
	circle(r = boltR);
    translate([-55, -30])
	circle(r = boltR);

    translate([48, 10])
	circle(r = boltR);
    translate([55, -30])
	circle(r = boltR);

}

module upperBracketFilletCut() {
    difference() {
	union() {
	    translate([75.5, 85]) {
		circle(r=10);
		translate([5, -10])
		    circle(r=10);
		translate([14, -25])
		    circle(r=10);
		translate([20, -40])
		    circle(r=10);
	    }
	}
	translate([72.5, 90])
	    circle(r=10);
    }
}

module upperBracketFilletCuts() {
    upperBracketFilletCut();
    mirror([1,0,0])
	upperBracketFilletCut();
}
module upperBracketBaseShape() {
    n17fw = v(nema_17, "faceWidth");
    n17fh = v(nema_17, "faceHeight");

    motorOverhang = baseMotorOffset + n17fh/2;

    hull() {
	circle(r=lazySusanOuterR + 4);
	translate([n17fw/2 + 30, motorOverhang]) circle(r=10);
	translate([-n17fw/2 - 30, motorOverhang]) circle(r=10);
    }

    
}

module baseUpperBracket() {
    lazySusanShadow();
    n17fw = v(nema_17, "faceWidth");
    n17fh = v(nema_17, "faceHeight");

    motorOverhang = baseMotorOffset + n17fh/2;

    %translate([0, baseMotorOffset, 0]) {
	translate([-n17fw/2, -n17fh / 2, 0]) {
	    square([n17fw, n17fh]);
	}
    }
    
    difference() {
	union() {
	    upperBracketBaseShape();
	}

	translate([0, baseMotorOffset, 0]) {
	    translate([-n17fw/2-5, -n17fh/2-5, 0])
		square([n17fw+10, n17fh+50]);

	    for (pt = coverHoles(n17fh, n17fw, 10)) {
		translate(pt) {
		    circle(r=m3TapR);
		}
	    }
	    upperBracketBoltHoles();
	}
	
	circle(r=lazySusanInnerR);

	for (x = [-66.1, 66.1]) {
	    for (y = [-66.1, 66.1]) {
		translate([x,y,0])
		    circle(r=openBoltR);
	    }
	}
    }
	    
}

module upperBracketSpacer() {
    n17fw = v(nema_17, "faceWidth");
    n17fh = v(nema_17, "faceHeight");
    difference() {
	upperBracketBaseShape();
	circle(r=lazySusanOuterR + 5);

	translate([0, baseMotorOffset, 0]) {
	    translate([-n17fw/2-5, -n17fh/2-5, 0])
		square([n17fw+10, n17fh+50]);
	    upperBracketBoltHoles();

	}
	upperBracketFilletCuts();
    }
}

module upperBracketMotorMount() {
    n17fw = v(nema_17, "faceWidth");
    n17fh = v(nema_17, "faceHeight");
    boX = v(nema_17, "boltOffsetX");
    boY = v(nema_17, "boltOffsetY");
    difference() {
	upperBracketBaseShape();
	circle(r=lazySusanOuterR + 5);

	translate([0, baseMotorOffset, 0]) {
	    //translate([-n17fw/2-5, -n17fh/2-5, 0])
	    //square([n17fw+10, n17fh+50]);
	    upperBracketBoltHoles();
	    circle(r=v(nema_17, "faceCircleR"));
	    for (x = [-boX, boX]) {
		for (y = [-boY, boY]) {
		    translate([x,y,0]) {
			circle(r=m3R);
		    }
		}
	    }
	}
	upperBracketFilletCuts();
    }
}


module armGear() {
    hiddenTeeth = 26;
    armLen = 10 * 25;

    difference() {
	union() {
	    hull() {
		circle(r = gearInnerRadius(mmTooth, armTeeth)); 
		translate([armLen, 0, 0]) {
		    circle(r=12);
		}
	    }
	    
	    rotate([0, 0, 45]) {
		projection() {
		    gear(mmTooth, armTeeth, teeth_to_hide=hiddenTeeth, pressure_angle=pressureAngle);
		}
	    }
	}

	circle(r = boltR);
	translate([armLen, 0, 0]) {
	    circle(r = boltR);
	}

    }


}

module mGear() {
    difference() {
	projection() {
	    gear(mmTooth, mTeeth, pressure_angle=pressureAngle);
	}

	difference() {
	    circle(r=v(nema_17, "shaftR"));
	    translate([v(nema_17, "shaftFlat"), -3, 0])
		square([6,6]);
	}
    }
    
}
module mGearSpacer() {
    difference() {
	circle(r=inner_radius(mmTooth, mTeeth)-1);
	circle(r=v(nema_17, "shaftR")+0.3);
    }
}
	    


function gearInnerRadius(toothSize, teethCount)=
    toothSize * (teethCount/2-1) / pi;

function armAxleSpace() = pitch_radius(mmTooth, mTeeth) + pitch_radius(mmTooth, armTeeth);



module armMountExterior() {
    boX = v(nema_17, "boltOffsetX");
    boY = v(nema_17, "boltOffsetY");
    fh = v(nema_17, "faceHeight");
    fw = v(nema_17, "faceWidth");
    
    difference() {
	hull() {
	    circle(r=20);
	    translate([-armAxleSpace(), 0]) {
		for (x = [-boX, boX]) {
		    for (y = [-boY, boY]) {
			translate([x,y,0]) {
			    circle(r=25);
			}
		    }
		}
		translate([-v(nema_17, "faceWidth") - 15, 0, 0]) {
		    circle(r=20);
		    translate([-armBoltSpace, 0])
			circle(r=20);
		}
	    }
	}

	circle(r=boltR);
	translate([-armAxleSpace(), 0]) {
	    circle(r=v(nema_17, "faceCircleR"));
	    for (x = [-boX, boX]) {
		for (y = [-boY, boY]) {
		    translate([x,y,0]) {
			circle(r=m3R);
		    }
		}
	    }

	    %translate([-v(nema_17, "faceHeight")/2, -v(nema_17, "faceWidth")/2])
		 square([v(nema_17, "faceHeight"), v(nema_17, "faceWidth")]);


	    for (pt = coverHoles(fh, fw, 10)) {
		translate([pt[1], pt[0]])
		    circle(r=m3TapR);
	    }

	    /*
	    for (x = [-fw/2, 0, fw/2]) {
		translate([-v(nema_17, "faceHeight")/2 - 10, x])
		    circle(r=m3TapR);
	    }

	    for (y = [-fh/2, 0, fh/2]) {
		translate([y, -v(nema_17, "faceHeight")/2 - 10])
		    circle(r=m3TapR);
		translate([y, v(nema_17, "faceHeight")/2 + 10])
		    circle(r=m3TapR);
	    }
	    */
	    translate([-v(nema_17, "faceWidth") - 15, 0, 0]) {
		circle(r=boltR);
		translate([-armBoltSpace, 0])
		    circle(r=boltR);
	    }
	}
    }
}

module motorShieldWasher() {
    fh = v(nema_17, "faceHeight");
    boY = v(nema_17, "boltOffsetY");
    difference() {
	minkowski() {
	    translate([-fh / 2 - 3, -3])
		square([fh + 6, 6]);
	    circle(r=2);
	}

	for (y = [-fh/2, 0, fh/2]) {
	    translate([y,0]) {
		circle(r=m3R);
	    }
	}
    }
}


module armMountInterior() {
    difference() {
	hull() {
	    circle(r=20);
	    translate([-armAxleSpace(), 0]) {
		translate([-v(nema_17, "faceWidth") - 15, 0, 0]) {
		    circle(r=20);
		    translate([-armBoltSpace, 0])
			circle(r=20);
		}
	    }
	}

	circle(r=boltR);
	translate([-armAxleSpace(), 0]) {
	    circle(r=v(nema_17, "shaftR") + 0.5);
	    translate([-v(nema_17, "faceWidth") - 15, 0, 0]) {
		circle(r=boltR);
		translate([-armBoltSpace, 0])
		    circle(r=boltR);
	    }
	}
    }
}

module armMountSpacer() {
    difference() {
	hull() {
	    circle(r=20);
	    translate([-armBoltSpace, 0])
		circle(r=20);
	}
	circle(r=boltR);
	translate([-armBoltSpace, 0])
	    circle(r=boltR);
    }
}

module simpleSpacer() {
    difference() {
	circle(r=10);
	circle(r=boltR);
    }
}


module buttonBoard(buttonR) {
    buttonPosX = [80, 160, 80, 160, 80, 160];
    buttonPosY = [50, 50, 110, 110, 170, 170];
    
    difference() {
	square([240, 240]);

	for (x = buttonPosX, y = buttonPosY) {
	    translate([x,y])
		circle(r=buttonR);
	}
	for (x = [19, 240-19]) {
	    for (y = [19, 65, 120, 240 - 65, 240-19]) {
		translate([x,y])
		    circle(r=3);
		translate([y,x])
		    circle(r=3);
	    }
	}
    }
}

// much of the structure is made with .25"/6mm acrylic and then spacers are made with whatever size necessary to get the motor gear and arm to move freely but not be sloppy.  This can be done by using .125"/3mm acrylic and sanding it down a bit or just finding pieces that are at the edge of their tolerances because the tolerances on acrylic thicknesses often vary by as much as .020" (and when I made it I bought one sheet of acrylic for the large key parts and most of the spacers were made from scrap so I had lots to choose from).

// the stack of pieces is held together with 1/4"-20 bolts.  Must use a nylock or jam nuts on the bolt that acts as an axle to keep it loose but the other two bolts are kept tight.

// I've commented out the parts that aren't used in the simplified bicycle version of the bubble machine.

//minkowski() {
//    union() {
translate([-100, 200])
    armGear();  // the arm itself (0.25" acrylic)
translate([-armAxleSpace() - 10, 0])
    rotate([0,0,-90])
    mGear();    // the gear on the motor that drives the arm (0.25" acrylic)
translate([-armAxleSpace() + 10, 0])
    mGearSpacer();  // gear spacer to keep motor gear engaged with arm (thin acrylic)
translate([-armAxleSpace() + 22, 0])
    mGearSpacer();
//translate([-armAxleSpace() + 34, 0])
//    mGearSpacer();

translate([30, 90])
    armMountExterior();  // top layer of arm mount and includes motor mounts, 9 small holes around motor mount should be tapped m3, used to hold motor cover (0.25" acrylic)
translate([30, -70])
    armMountInterior();  // bottom layer of arm mount (0.25" acrylic)
translate([-50, -140])
    armMountSpacer();    // spacer sandwiched between armMountExterior and armMountInterior so that arm can float, captured on its axle. (2 x 0.25" acrylic)
translate([-50, -200])
    armMountSpacer();
translate([10, -140])
    simpleSpacer();      // spacer between arm and arm mounts interior and exterior.  (thin acrylic)
translate([32, -140])
    simpleSpacer();

// To protect the motors from bubble solution (a strong and penetrating
// degreaser), I cover the motors with a small piece of shelf liner that
// is sewn into a cover and then bolted to the arm mount exterior.  These
// are the washers that clamp the cover to the arm mount.  (cut from thin acrylic)
translate([-100,0])
    motorShieldWasher();  
translate([-100,15])
    motorShieldWasher();
translate([-100,-15])
    motorShieldWasher();


/*
translate([-300, 150]) {
    baseGear();
    //towerShadow();
}
translate([-300, -150]) {
    underBaseGear();
    //towerShadow();
}
translate([-550, -50])
    upperBracketSpacer();
translate([-550, 50])
    upperBracketMotorMount();
    }
translate([-550, -150])
    baseUpperBracket();

translate([200, 20])
buttonBoard(buttonR);
translate([200, -320])
buttonBoard(botButtonR);
*/

//    circle(r=0.1);
//}

//echo(coverHoles(fh, fw, extra));
