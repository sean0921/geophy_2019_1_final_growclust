# Growclust relocation result discussion 

## before Relocation

![](focal_profile.png)

## after Relocation via GrowClust

![](focal_profile_gc.png)
![](focal_profile_clust.png)

## Steps

1. Get [GrowClust](https://github.com/dttrugman/GrowClust.git), compile it with `CFLAGS = -O -mcmodel=large`, install it in `$PATH`(recommended).
2. Our event cluster folder: `201807030920_inv`, enter it and just run: `growclust GC_inv.inp`, let it run.
3. Read GrowClust Manual Chapter 4.1, "Relocated catalog file", use below information to let Generic Mapping Tools draw it:
    -  column 8 (relocated latitude)
    -  column 9 (relocated longitude)
    -  column 10 (relocated depth)
    -  column 11 (magniture)
    -  column 23 (initial latitude)
    -  column 24 (initial longitude)
    -  column 25 (initial depth)
 4. modify example script provided by teacher.
 5. done!

# Claim

* just for study, if there's any copyright problem, please add issue here and I'll reply ASAP.
