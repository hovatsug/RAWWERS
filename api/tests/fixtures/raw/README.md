# Real camera-file headers

Header slices (the first 40-256 KB) of real RAW files, used to test that gear
verification can read what real cameras write. They are not decodable images:
every one is cut off long before the pixel data, which is the point - EXIF
lives in the header, and the server only ever reads a header.

These exist because the first version of the reader was tested only against
JPEGs synthesised by Pillow, and every failure that mattered turned up the
moment a real file was used: Canon CR3 and Fujifilm RAF unreadable, Sony
bodies reporting no serial, a Nikon D850 with no lens data, and Canon writing
`0` for a lens's maximum aperture.

Source: https://raw.pixls.us/ - contributors there release each file into the
public domain (CC0). Original files, full length in the archive:

| fixture | archive path |
| --- | --- |
| canon_eos_r5.cr3.head | Canon/EOS R5/Canon_EOS_R5_CRAW_ISO_100_nocrop_nodual.CR3 |
| canon_eos_r.cr3.head | Canon/EOS R/Canon_EOS_R_CRAW_ISO_100.CR3 |
| sony_ilce7m4.arw.head | Sony/ILCE-7M4/ILCE-7M4_DSC06674_FullFrame-LossLess-Compressed-Large.ARW |
| sony_ilce7m3.arw.head | Sony/ILCE-7M3/_DSC0009.ARW |
| nikon_d850.nef.head | Nikon/D850/Nikon-D850-14bit-compressed.NEF |
| nikon_z6.nef.head | Nikon/Z 6/DSC_0750.NEF |
| panasonic_dcs5.rw2.head | Panasonic/DC-S5/P1047510.RW2 |
| fujifilm_xt4.raf.head | Fujifilm/X-T4/DSCF0266.RAF |

Full sizes, for scale: 16-58 MB each.
