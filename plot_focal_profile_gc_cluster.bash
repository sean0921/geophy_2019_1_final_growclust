#!/usr/bin/env bash
ps=focal_profile_clust.ps
cpt=topo.cpt
catalog=out_201807030920.growclust_cat
clust=out_201807030920.growclust_clust
data_dir="$HOME"/data/grdfile/

#=== cut the grd file
# gmt grdcut input.grd -Goutput.grd -Rrnage
#gmt grdcut "$data_dir"TW_topo.grd -G"$data_dir"YM_topo.grd -R120.5/121.25/23.00/23.33

# generate cpt file
gmt makecpt -Cearth -T-1000/4000/100 > "$cpt"
# plot topography
gmt grdimage "$data_dir"TW_topo.grd -R120.75/121.5/23.00/23.50 -JM13 -BWeSn -Ba -C"$cpt" -P -X3 -Y18 -K > "$ps"
# plot the coast
gmt pscoast -R -JM -Df -W1 -K -O >> "$ps"
# plot faults
gmt psxy "$data_dir"CGS_fault.gmt -R -JM -W2,250/0/0 -O -K >>"$ps"
# plot the scale bar
gmt psscale -C"$cpt" -Dx14/0+w9/.5+e -Ba500+l"Elevation (m)" -O -K >> "$ps"
# plot Earthquakes (cluster)
#awk '{print $9,$8,$11/12}' "$catalog" | gmt psxy -R -JM -Sc -K -O >> "$ps"
awk '{if (NF==22 && $1==1) print $12,$11,$4/12}' "$clust" | gmt psxy -R -JM -Sc -Wred -K -O >> "$ps"
awk '{if (NF==22 && $1==2) print $12,$11,$4/12}' "$clust" | gmt psxy -R -JM -Sc -Wblue -K -O >> "$ps"
awk '{if (NF==22 && $1==3) print $12,$11,$4/12}' "$clust" | gmt psxy -R -JM -Sc -Wgreen -K -O >> "$ps"
awk '{if (NF==22 && $1>3)  print $12,$11,$4/12}' "$clust" | gmt psxy -R -JM -Sc -W195/214/25 -K -O >> "$ps"
# plot focal mechanism
gmt psmeca 201807030920.foc -R -JM -Sa1.0/14p/6 -Gred -O -K >> "$ps"

# plot AA' line
# coord. of A1 & A2
A1_lon=120.85
A1_lat=23.16
A2_lon=121.00
A2_lat=23.16
# plot a line
echo "$A1_lon" "$A1_lat" > tmp
echo "$A2_lon" "$A2_lat" >> tmp
gmt psxy tmp -R -JM -W2,238/91/78 -K -O >> "$ps"
# text of A1
echo "$A1_lon" "$A1_lat" A1 > tmp
gmt psxy tmp -R -JM -Sc.8 -G238/91/78 -W1 -K -O >> "$ps"
gmt pstext tmp -R -JM -F+f16p,0,blue -K -O >> "$ps"
# text of A2
echo "$A2_lon" "$A2_lat" A2 > tmp
gmt psxy tmp -R -JM -Sc.8 -G238/91/78 -W1 -K -O >> "$ps"
gmt pstext tmp -R -JM -F+f16p,0,blue -O -K >> "$ps"

# insert a small map
gmt pscoast -R119.9/122.1/21.8/25.4 -JM3 -Bwesn -Ba -Df -W1 -S255 -G230 -X10 -K -O --MAP_FRAME_TYPE=inside >> "$ps"
# method1
#gmt psbasemap -R -JM -D120.5/121.25/23.00/23.33 -F+p1+gred -O -K >> "$ps"
# method2
echo 120.75 23.00 > area
echo 120.75 23.50 >> area
echo 121.50 23.50 >> area
echo 121.50 23.00 >> area
echo 120.75 23.00 >> area
gmt psxy area -R -JM -W2,red -O -K >> "$ps"

# plot the seismicity profile
width=10
width2=20
depth=15

# reference format
#awk '{if (NF==22 && $1==1) print $12,$11,$4/12}' "$clust" | gmt psxy -R -JM -Sc -Wred -K -O >> "$ps"
#awk '{if (NF==22 && $1==2) print $12,$11,$4/12}' "$clust" | gmt psxy -R -JM -Sc -Wblue -K -O >> "$ps"
#awk '{if (NF==22 && $1==3) print $12,$11,$4/12}' "$clust" | gmt psxy -R -JM -Sc -Wgreen -K -O >> "$ps"
#awk '{if (NF==22 && $1>3)  print $12,$11,$4/12}' "$clust" | gmt psxy -R -JM -Sc -W195/214/25 -K -O >> "$ps"

# cluster No.1
#awk '{printf("%f %f %f %f\n",$9,$8,$10,$11)}' "$clust" | \
awk '{if(NF==22 && $1==1) printf("%f %f %f %f\n",$12,$11,$13,$4)}' "$clust" | \
gmt project -C"$A1_lon"/"$A1_lat" -E"$A2_lon"/"$A2_lat" -W-"$width"/"$width" -Q > catalog_profile.gmt
echo "$A1_lon" "$A1_lat" 0 0 > end_pts
echo "$A2_lon" "$A2_lat" 0 0 >> end_pts
gmt project end_pts -C"$A1_lon"/"$A1_lat" -E"$A2_lon"/"$A2_lat" -W-"$width"/"$width" -Q > edge.gmt
mdis=$(gmt gmtinfo edge.gmt -i4 -C -o1)
#echo $mdis
gmt psbasemap -R0/"$mdis"/0/"$depth" -JX15/-7.5 -BwESn -Bxa+l"Distance (km)" -Bya+l"Depth (km)" -X-11 -Y-10 -K -O >> "$ps"
awk '{print $5,$3,$4/12}' catalog_profile.gmt | gmt psxy -R -JX -Sc -Wred -K -O >> "$ps"

# cluster No.2
#awk '{printf("%f %f %f %f\n",$9,$8,$10,$11)}' "$clust" | \
awk '{if(NF==22 && $1==2) printf("%f %f %f %f\n",$12,$11,$13,$4)}' "$clust" | \
gmt project -C"$A1_lon"/"$A1_lat" -E"$A2_lon"/"$A2_lat" -W-"$width"/"$width" -Q > catalog_profile.gmt
##echo "$A1_lon" "$A1_lat" 0 0 > end_pts
##echo "$A2_lon" "$A2_lat" 0 0 >> end_pts
##gmt project end_pts -C"$A1_lon"/"$A1_lat" -E"$A2_lon"/"$A2_lat" -W-"$width"/"$width" -Q > edge.gmt
##mdis=$(gmt gmtinfo edge.gmt -i4 -C -o1)
###echo $mdis
##gmt psbasemap -R0/"$mdis"/0/"$depth" -JX15/-7.5 -BwESn -Bxa+l"Distance (km)" -Bya+l"Depth (km)" -X-11 -Y-10 -K -O >> "$ps"
awk '{print $5,$3,$4/12}' catalog_profile.gmt | gmt psxy -R -JX -Sc -Wblue -K -O >> "$ps"

# cluster No.3
#awk '{printf("%f %f %f %f\n",$9,$8,$10,$11)}' "$clust" | \
awk '{if(NF==22 && $1==3) printf("%f %f %f %f\n",$12,$11,$13,$4)}' "$clust" | \
gmt project -C"$A1_lon"/"$A1_lat" -E"$A2_lon"/"$A2_lat" -W-"$width"/"$width" -Q > catalog_profile.gmt
##echo "$A1_lon" "$A1_lat" 0 0 > end_pts
##echo "$A2_lon" "$A2_lat" 0 0 >> end_pts
##gmt project end_pts -C"$A1_lon"/"$A1_lat" -E"$A2_lon"/"$A2_lat" -W-"$width"/"$width" -Q > edge.gmt
##mdis=$(gmt gmtinfo edge.gmt -i4 -C -o1)
###echo $mdis
##gmt psbasemap -R0/"$mdis"/0/"$depth" -JX15/-7.5 -BwESn -Bxa+l"Distance (km)" -Bya+l"Depth (km)" -X-11 -Y-10 -K -O >> "$ps"
awk '{print $5,$3,$4/12}' catalog_profile.gmt | gmt psxy -R -JX -Sc -Wgreen -K -O >> "$ps"

# other clusters
#awk '{printf("%f %f %f %f\n",$9,$8,$10,$11)}' "$clust" | \
awk '{if(NF==22 && $1>3) printf("%f %f %f %f\n",$12,$11,$13,$4)}' "$clust" | \
gmt project -C"$A1_lon"/"$A1_lat" -E"$A2_lon"/"$A2_lat" -W-"$width"/"$width" -Q > catalog_profile.gmt
##echo "$A1_lon" "$A1_lat" 0 0 > end_pts
##echo "$A2_lon" "$A2_lat" 0 0 >> end_pts
##gmt project end_pts -C"$A1_lon"/"$A1_lat" -E"$A2_lon"/"$A2_lat" -W-"$width"/"$width" -Q > edge.gmt
##mdis=$(gmt gmtinfo edge.gmt -i4 -C -o1)
###echo $mdis
##gmt psbasemap -R0/"$mdis"/0/"$depth" -JX15/-7.5 -BwESn -Bxa+l"Distance (km)" -Bya+l"Depth (km)" -X-11 -Y-10 -K -O >> "$ps"
awk '{print $5,$3,$4/12}' catalog_profile.gmt | gmt psxy -R -JX -Sc -W195/214/25 -K -O >> "$ps"

#==== plot the focal mechanism
gmt project 201807030920.foc -C"$A1_lon"/"$A1_lat" -E"$A2_lon"/"$A2_lat" -W-"$width"/"$width" -Q > focal_profile.gmt
awk '{print $1,$2,$3,$4,$5,$6,$7,$8,$9}' focal_profile.gmt | \
gmt pscoupe -R -JX -Sa1.0 -Gred -Aa"$A1_lon"/"$A1_lat"/"$A2_lon"/"$A2_lat"/90/""$width"2"/0/"$depth" -O -K >> "$ps"

gmt psbasemap -R0/10/0/10 -JX15/-7.5 -BwESn  -X3 -Y-9.5 -K -O >> "$ps"

# ==== 圖例框與圖例內容 ====
gmt psxy -R -J -O -K -W0.05c,black >> "$ps" << BOXEND
1 1
6 1
6 6
1 6
1 1
BOXEND

echo "2 2 0.5" | gmt psxy -R -J -Sc -Wred -K -O >> "$ps"
echo "2 3 0.5" | gmt psxy -R -J -Sc -Wblue -K -O >> "$ps"
echo "2 4 0.5" | gmt psxy -R -J -Sc -Wgreen -K -O >> "$ps"
echo "2 5 0.5" | gmt psxy -R -J -Sc -W195/214/25 -K -O >> "$ps"
echo "3 2 Cluster 1" | gmt pstext -R -J -O -K -F+f14p+jML >> "$ps"
echo "3 3 Cluster 2" | gmt pstext -R -J -O -K -F+f14p+jML >> "$ps"
echo "3 4 Cluster 3" | gmt pstext -R -J -O -K -F+f14p+jML >> "$ps"
echo "3 5 Other clusters" | gmt pstext -R -J -O `#-K` -F+f14p+jML >> "$ps"
