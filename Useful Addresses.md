# Memory

| Address  | Description                                                                                             |
| -------- | ------------------------------------------------------------------------------------------------------- |
| 0x0 (M0) | Lower PC for graphics draw                                                                              |
| 0x1 (M1) | Upper PC for graphics draw                                                                              |
| 0x2 (M2) | Value <= 7 that indicates which graphics page is used                                                   |
| 0x07D    | Possible some sort of counter until rerender happens? Is cleared before rendering, and set to 0xF after |
|          |                                                                                                         |

# Graphics

Table generated via regex:
`^  \/\/\s+(.*)\n(?:\s+\/\/.*\n)?\s+lbpx.*\/\/ (0x[a-f0-9]{3,4})`

| Address | Description                                                           |
| ------- | --------------------------------------------------------------------- |
| 0x1030  | Stage 0, Babytchi                                                     |
| 0x1040  | Stage 0, Babytchi hiding                                              |
| 0x1050  | Stage 0, Babytchi eating                                              |
| 0x1060  | Stage 0, Babytchi flattened                                           |
| 0x1070  | Stage 0, Babytchi happy                                               |
| 0x1080  | Stage 0, Babytchi looking left                                        |
| 0x1090  | Stage 0, Babytchi angry                                               |
| 0x10A0  | Stage 1, Marutchi upper half                                          |
| 0x10B0  | Stage 1, Marutchi lower half                                          |
| 0x10C0  | Stage 1, Marutchi happy upper half                                    |
| 0x10D0  | Stage 1, Marutchi eating upper half                                   |
| 0x10E0  | Stage 1, Marutchi lower half                                          |
| 0x10F0  | Stage 1, Marutchi looking left, upper half                            |
| 0x1100  | Stage 1, Marutchi sleeping, upper half                                |
| 0x1110  | Black screen. Turn on all pixels                                      |
| 0x1120  | Stage 1, Marutchi sleeping?, turned left, upper half                  |
| 0x1130  | Stage 1, Marutchi happy, upper half                                   |
| 0x1140  | Stage 2a, Tamatchi upper half                                         |
| 0x1150  | Stage 2a, Tamatchi lower half, left foot forward                      |
| 0x1160  | Stage 2a, Tamatchi lower half, feet transitioning                     |
| 0x1170  | Stage 2a, Tamatchi lower half, right foot forward                     |
| 0x1180  | Rectangular face with teeth                                           |
| 0x1190  | Possible base for teeth                                               |
| 0x11A0  | Stage 2b, KuchiTamatchi upper half, neutral                           |
| 0x11B0  | Stage 2b, KuchiTamatchi upper half, squished mouth                    |
| 0x11C0  | Stage 2b, KuchiTamatchi upper half, open mouth                        |
| 0x11D0  | Stage 2b, KuchiTamatchi upper half, looking right, closed eyes        |
| 0x1230  | Stage 3a, Mametchi upper half, turned left                            |
| 0x1240  | Stage 3a, Mametchi lower half, turned left                            |
| 0x1250  | Stage 3a, Mametchi upper half, front facing                           |
| 0x1260  | Stage 3a, Mametchi lower half, right leg forward                      |
| 0x1270  | Stage 3a, Mametchi upper half, mouth open, eating                     |
| 0x1280  | Stage 3a, Mametchi lower half, extended back for eating               |
| 0x1290  | Stage 3a, Mametchi upper half, sleeping                               |
| 0x12A0  | Stage 3b, Ginjirotchi upper half, turned left                         |
| 0x12B0  | Stage 3b, Ginjirotchi upper half, front facing                        |
| 0x12C0  | Stage 3b, Ginjirotchi upper half, back facing?                        |
| 0x12D0  | Stage 3b, Ginjirotchi bottom half                                     |
| 0x12E0  | Stage 3b, Ginjirotchi upper half, open mouth, eating                  |
| 0x12F0  | Stage 3b, Ginjirotchi upper half, right facing, sleeping?             |
| 0x1300  | Stage 3c, Maskutchi upper half, left facing, big eyes                 |
| 0x1310  | Stage 3c, Maskutchi lower half, leaning right                         |
| 0x1320  | Stage 3c, Maskutchi lower half, leaning left                          |
| 0x1330  | Tombstone top, WWW symbol                                             |
| 0x1340  | Tombstone top, line                                                   |
| 0x1350  | Stage 3c, Maskutchi upper half, front facing, small eyes              |
| 0x1360  | Stage 3c, Maskutchi upper half, front facing, big eyes pointing right |
| 0x1370  | Stage 3c, Maskutchi upper half, left facing, small eyes               |
| 0x1380  | Stage 3d, Kuchipatchi upper half, left facing                         |
| 0x1390  | Stage 3d, Kuchipatchi upper half, open mouth, happy                   |
| 0x13A0  | Stage 3d, Kuchipatchi upper half, sleeping?                           |
| 0x13B0  | Stage 3d, Kuchipatchi upper half, front facing                        |
| 0x13C0  | Stage 3e, Nyorotchi lower half, leaning left                          |
| 0x13D0  | Stage 3e, Nyorotchi lower half, leaning right                         |
| 0x13E0  | Stage 3e, Nyorotchi lower half, filled in                             |
| 0x13F0  | Stage 4, Bill upper half                                              |
| 0x1400  | Stage 4, Bill lower half                                              |
| 0x1410  | Stage 4, Bill upper half, sad                                         |
| 0x1420  | Stage 4, Bill lower half, sad                                         |
| 0x1430  | Stage 4, Bill upper half, Laughing                                    |
| 0x1440  | Stage 4, Bill upper half, sleeping                                    |
| 0x1450  | Cloud?                                                                |
| 0x1460  | Egg, upper half, position 1                                           |
| 0x1470  | Egg, lower half, position 1                                           |
| 0x1480  | Egg, upper half, position 2                                           |
| 0x1490  | Egg, lower half, position 2                                           |
| 0x14A0  | Egg hatching, upper half                                              |
| 0x14B0  | Egg hatching, lower half                                              |
| 0x14C0  | Sparkles, large one on the left                                       |
| 0x14D0  | Sparkles, large one on the right                                      |
| 0x14E0  | Angel, upper half                                                     |
| 0x14F0  | Angel, lower half                                                     |
| 0x1500  | Large 0 text                                                          |
| 0x1504  | Large 1 text                                                          |
| 0x1508  | Large 2 text                                                          |
| 0x150C  | Large 3 text                                                          |
| 0x1510  | Large 4 text                                                          |
| 0x1514  | Large 5 text                                                          |
| 0x1518  | Large 6 text                                                          |
| 0x151C  | Large 7 text                                                          |
| 0x1520  | Large 8 text                                                          |
| 0x1524  | Large 9 text                                                          |
| 0x1528  | Small 0 text                                                          |
| 0x152C  | Small 1 text                                                          |
| 0x1530  | Small 2 text                                                          |
| 0x1534  | Small 3 text                                                          |
| 0x1538  | Small 4 text                                                          |
| 0x153C  | Small 5 text                                                          |
| 0x1540  | Small 6 text                                                          |
| 0x1544  | Small 7 text                                                          |
| 0x1548  | Small 8 text                                                          |
| 0x154C  | Small 9 text                                                          |
| 0x1550  | Filled in right pointing arrow                                        |
| 0x1554  | Unfilled right pointing arrow                                         |
| 0x1600  | Large, centered 0 text                                                |
| 0x1608  | Large, centered 1 text                                                |
| 0x1610  | Large, centered 2 text                                                |
| 0x1618  | Large, centered 3 text                                                |
| 0x1620  | Large, centered 4 text                                                |
| 0x1628  | Large, centered 5 text                                                |
| 0x1630  | Large, centered 6 text                                                |
| 0x1638  | Large, centered 7 text                                                |
| 0x1640  | Large, centered 8 text                                                |
| 0x1648  | Large, centered 9 text                                                |
| 0x1650  | AM vertical text                                                      |
| 0x1658  | PM vertical text                                                      |
| 0x1660  | S\| text - Beginning of SET                                           |
| 0x1668  | ET text - Ending of SET                                               |
| 0x1670  | OI text                                                               |
| 0x1678  | VS game result text                                                   |
| 0x1680  | Bread food, complete                                                  |
| 0x1688  | Bread food, first bite                                                |
| 0x1690  | Bread food, second bite                                               |
| 0x1698  | Clear/empty section                                                   |
| 0x16A0  | Snack food, complete                                                  |
| 0x16A8  | Snack food, first bite                                                |
| 0x16B0  | Snack food, second bite                                               |
| 0x16B8  | Most of "FF"                                                          |
| 0x16C0  | Stage 0, babytchi                                                     |
| 0x16C8  | yr lowercase, year indicator                                          |
| 0x16D0  | Scale icon                                                            |
| 0x16D8  | OZ uppercase, weight indicator                                        |
| 0x16E0  | Filled in heart, satisfied                                            |
| 0x16E8  | Empty heart, unsatisfied                                              |
| 0x16F0  | Stinky poop, right arrows                                             |
| 0x16F8  | Stinky poop, left arrows                                              |
| 0x1700  | Big Z with black background, sleeping                                 |
| 0x1708  | Smaller Z with dots and black background, sleeping                    |
| 0x1710  | Sickness skull                                                        |
| 0x1718  | Success sparkle                                                       |
| 0x1720  | Angry ticks                                                           |
| 0x1728  | Smaller ticks                                                         |
| 0x1730  | Left filled in arrow                                                  |
| 0x1738  | Right filled in arrow                                                 |
| 0x1740  | Me cut off. Start of Meal                                             |
| 0x1748  | ea cut off. Middle of Meal                                            |
| 0x1750  | l. end of Meal                                                        |
| 0x1758  | Sn cut off. Start of Snack                                            |
| 0x1760  | na cut off. Middle of Snack                                           |
| 0x1768  | ck cut off. End of Snack                                              |
| 0x1770  | Hu. Start of Hungry                                                   |
| 0x1778  | ng. Middle of Hungry                                                  |
| 0x1780  | ry. End of Hungry                                                     |
| 0x1788  | Ha cut off. Start of Happy                                            |
| 0x1790  | ap cut off. Middle of Happy                                           |
| 0x1798  | py. End of Happy                                                      |
| 0x17A0  | Di. Start of Dicipline                                                |
| 0x17A8  | sci. Middle of Dicipline                                              |
| 0x17B0  | pli. Middle of Dicipline                                              |
| 0x17B8  | ne. End of Dicipline                                                  |
| 0x17C0  | Wide O                                                                |
| 0x17C8  | Wide N                                                                |
| 0x17D0  | Big Z with clear background. Sleeping                                 |
| 0x17D8  | Little Z with dots and clear background. Sleeping                     |
| 0x17E0  | The remander of these are blank                                       |