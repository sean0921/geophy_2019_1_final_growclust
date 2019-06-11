#!/bin/bash
ps=focal_profile.ps
cpt=topo.cpt
catalog=201901281210.list

#=== cut the grd file
# gmt grdcut input.grd -Goutput.grd -Rrnage
#gmt grdcut ../TW_topo.grd -G../YM_topo.grd -R121.25/122.0/25.00/25.50 

# generate cpt file
gmt makecpt -Cearth -T-1000/1000/10 > $cpt
# plot topography
gmt grdimage ../YM_topo.grd -R121.45/121.70/25.05/25.30 -JM13 -BWeSn -Ba -C$cpt -P -X2 -Y13 -K > $ps
# plot the coast
gmt pscoast -R -JM -Df -W1 -K -O >> $ps
#plot faults
gmt psxy ../CGS_fault.gmt -R -JM -W2,250/0/0 -O -K >>$ps
# plot the scale bar
gmt psscale -C$cpt -Dx14/0+w9/.5+e -Ba100+l"Elevation (m)" -O -K >> $ps
# plot Earthquakes
awk '{print $8,$9,$11/12}' $catalog | gmt psxy -R -JM -Sc -K -O >> $ps
# plot focal mechanism
gmt psmeca 201901281210.foc -R -JM -Sa1.0/14p/6 -Gred -O -K >> $ps

# plot AA' line
# coord. of A1 & A2
A1_lon=121.5
A1_lat=25.185
A2_lon=121.65
A2_lat=25.185
# plot a line
echo $A1_lon $A1_lat > tmp
echo $A2_lon $A2_lat >> tmp
gmt psxy tmp -R -JM -W2,238/91/78 -K -O >> $ps
# text of A1
echo $A1_lon $A1_lat A1 > tmp
gmt psxy tmp -R -JM -Sc.8 -G238/91/78 -W1 -K -O >> $ps
gmt pstext tmp -R -JM -F+f16p,0,blue -K -O >> $ps
# text of A2
echo $A2_lon $A2_lat A2 > tmp
gmt psxy tmp -R -JM -Sc.8 -G238/91/78 -W1 -K -O >> $ps
gmt pstext tmp -R -JM -F+f16p,0,blue -O -K >> $ps

# insert a small map
gmt pscoast -R119.9/122.1/21.8/25.4 -JM3 -Bwesn -Ba -Df -W1 -S255 -G230 -X10 -K -O --MAP_FRAME_TYPE=inside >> $ps
# method1
#gmt psbasemap -R -JM -D121.45/121.70/25.05/25.30 -F+p1+gred -O -K >> $ps
# method2
echo 121.45 25.05 > area
echo 121.45 25.30 >> area
echo 121.70 25.30 >> area
echo 121.70 25.05 >> area
echo 121.45 25.05 >> area
gmt psxy area -R -JM -W2,red -O -K >> $ps

# plot the seismicity profile
width=10
width2=20
depth=15
awk '{printf("%f %f %f %f\n",$8,$9,$10,$11)}' $catalog | \
gmt project -C$A1_lon/$A1_lat -E$A2_lon/$A2_lat -W-$width/$width -Q > catalog_profile.gmt
echo $A1_lon $A1_lat 0 0 > end_pts 
echo $A2_lon $A2_lat 0 0 >> end_pts
gmt project end_pts -C$A1_lon/$A1_lat -E$A2_lon/$A2_lat -W-$width/$width -Q > edge.gmt
mdis=`gmt gmtinfo edge.gmt -i4 -C -o1`
#echo $mdis
gmt psbasemap -R0/$mdis/0/$depth -JX15/-7.5 -BwESn -Bxa+l"Distance (km)" -Bya+l"Depth (km)" -X-11 -Y-10 -K -O >> $ps
awk '{print $5,$3,$4/12}' catalog_profile.gmt | gmt psxy -R -JX -Sc -K -O >> $ps

#==== plot the focal mechanism
gmt project 201901281210.foc -C$A1_lon/$A1_lat -E$A2_lon/$A2_lat -W-$width/$width -Q > focal_profile.gmt
awk '{print $1,$2,$3,$4,$5,$6,$7,$8,$9}' focal_profile.gmt | \
gmt pscoupe -R -JX -Sa1.0 -Gred -Aa$A1_lon/$A1_lat/$A2_lon/$A2_lat/90/$width2/0/$depth -O >> $ps

