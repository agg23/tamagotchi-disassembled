                                                                                  // Addr   (inst)

// 
// Draws one of the asset graphics in the 0x1000 - 0x1800
// Toggles 0x07D to 0, then 0xF
// Disables interrupts until through rendering
// 
render_asset:
  ld    a,   m2                                                                    // 0x0    (0xFA2)
  and   a,   0x7                                                                   // 0x1    (0xC87)
  ld    b,   0x0                                                                   // 0x2    (0xE10)
  add   a,   a                                                                     // 0x3    (0xA80)
  add   a,   a                                                                     // 0x4    (0xA80)
  adc   b,   b                                                                     // 0x5    (0xA95)
  
  calz  clear_0x07D                                                                // 0x6    (0x512)
  
  // Call with
  // a = (m2 & 0x7) * 4
  // {b, a} make up the graphics page selection
  // This is the only way to reach the page of the jump table at 0x1000
  pset  0x10                                                                       // 0x7    (0xE50)
  // This will jp to set_f_0x07D
  jp    gfx_jp_ret_zp                                                              // 0x8    (0x20)

// 
// Writes 0xF to 0x07D
// Enables interrupts
// Preseves A, X
// 
set_f_0x07D:
  push  xp                                                                         // 0x9    (0xFC4)
  push  xh                                                                         // 0xA    (0xFC5)
  push  xl                                                                         // 0xB    (0xFC6)
  push  a                                                                          // 0xC    (0xFC0)
  calz  zero_a_xp                                                                  // 0xD    (0x5EF)
  ld    x,   0x7D                                                                  // 0xE    (0xB7D)
  // Set 0x07D to 0xF
  ld    mx,  0xF                                                                   // 0xF    (0xE2F)
  // Turn on interrupts
  set   f,   0x8                                                                   // 0x10   (0xF48)
  
  // Returns to caller
  jp    pop_a_x                                                                    // 0x11   (0x1A)

// 
// Writes 0 to 0x07D
// Clear interupt
// Preserves A, X
// 
clear_0x07D:
  push  xp                                                                         // 0x12   (0xFC4)
  push  xh                                                                         // 0x13   (0xFC5)
  push  xl                                                                         // 0x14   (0xFC6)
  push  a                                                                          // 0x15   (0xFC0)
  calz  zero_a_xp                                                                  // 0x16   (0x5EF)
  ld    x,   0x7D                                                                  // 0x17   (0xB7D)
  // Set 0x07D to 0
  ld    mx,  0x0                                                                   // 0x18   (0xE20)
  // Clear interrupt
  rst   f,   0x7                                                                   // 0x19   (0xF57)

// Fallthrough from clear_0x07D
// 
// Pops A, and XP, XH, XL, then returns to caller of set_f_0x07D/clear_0x07D
// 
pop_a_x:
  pop   a                                                                          // 0x1A   (0xFD0)
  pop   xl                                                                         // 0x1B   (0xFD6)
  pop   xh                                                                         // 0x1C   (0xFD5)
  pop   xp                                                                         // 0x1D   (0xFD4)
  // Return to caller of set_f_0x07D/clear_0x07D
  ret                                                                              // 0x1E   (0xFDF)

//
// Store 0x02 into 0x022/3
// Loop until 0x022 | 0x023 == 0
// Copy 0x026/7 to 0x028/9
// Returns
//
store_0x02_into_0x022_3:
  ld    x,   0x2                                                                   // 0x1F   (0xB02)
  calz  copy_xhl_to_0x022_or_loop_0x023                                            // 0x20   (0x53C)

//
// Copy 0x026-7 to 0x028-9, and zero 0x027
// Disables interrupts and 0x07D while performing this
// Returns
//
copy_0x026_7_to_8_9:
  ld    a,   0x0                                                                   // 0x21   (0xE00)
  ld    xp,  a                                                                     // 0x22   (0xE80)
  // X is 0x026
  ld    x,   0x26                                                                  // 0x23   (0xB26)
  calz  clear_0x07D                                                                // 0x24   (0x512)
  ldpx  a,   mx                                                                    // 0x25   (0xEE2)
  ld    b,   mx                                                                    // 0x26   (0xEC6)
  // A is 0x026
  // B is 0x027
  // Set 0x027 to 0
  ldpx  mx,  0x0                                                                   // 0x27   (0xE60)
  calz  set_f_0x07D                                                                // 0x28   (0x509)
  // Set 0x028 to orig 0x026
  ldpx  mx,  a                                                                     // 0x29   (0xEE8)
  // Set 0x029 to orig 0x027
  ld    mx,  b                                                                     // 0x2A   (0xEC9)
  ret                                                                              // 0x2B   (0xFDF)

//
// Copy XL, XH to 0x022, 0x023
// Disables interrupts and 0x07D while performing this
// Returns
//
copy_xhl_to_0x022:
  ld    a,   0x0                                                                   // 0x2C   (0xE00)
  ld    yp,  a                                                                     // 0x2D   (0xE90)
  // Y is 0x022
  ld    y,   0x22                                                                  // 0x2E   (0x822)
  calz  clear_0x07D                                                                // 0x2F   (0x512)
  // Copy XL, XH to 0x022, 0x023
  ld    my,  xl                                                                    // 0x30   (0xEAB)
  ldpy  a,   a                                                                     // 0x31   (0xEF0)
  ld    my,  xh                                                                    // 0x32   (0xEA7)
  calz  set_f_0x07D                                                                // 0x33   (0x509)
  ret                                                                              // 0x34   (0xFDF)

//
// ORs 0x022 against 0x023 and stores in A
// Returns
//
or_0x022_and_0x023:
  ld    a,   0x0                                                                   // 0x35   (0xE00)
  ld    yp,  a                                                                     // 0x36   (0xE90)
  ld    y,   0x23                                                                  // 0x37   (0x823)
  // Load 0x023
  ld    a,   my                                                                    // 0x38   (0xEC3)
  ld    y,   0x22                                                                  // 0x39   (0x822)
  // a = 0x022 | 0x023
  or    a,   my                                                                    // 0x3A   (0xAD3)
  ret                                                                              // 0x3B   (0xFDF)

//
// Copy XL, XH to 0x022, 0x023
// ORs 0x022 against 0x023 and stores in A
// Loops until 0x022 | 0x023 == 0
// Returns
//
copy_xhl_to_0x022_or_loop_0x023:
  call  copy_xhl_to_0x022                                                          // 0x3C   (0x42C)

loop_or_0x022_and_0x023:
  call  or_0x022_and_0x023                                                         // 0x3D   (0x435)
  // If 0x022 | 0x023 != 0, loop
  jp    nz,  loop_or_0x022_and_0x023                                               // 0x3E   (0x73D)
  ret                                                                              // 0x3F   (0xFDF)

//
// Clears the 0x100 page
// Clears 0x02A
// Returns
//
clear_page_0x100:
  calz  zero_a_xp                                                                  // 0x40   (0x5EF)
  // X is 0x02A
  ld    x,   0x2A                                                                  // 0x41   (0xB2A)
  // Set 0x02A to 0
  lbpx  mx,  0x0                                                                   // 0x42   (0x900)
  // Zero RAM starting at 0x100
  ld    a,   0x1                                                                   // 0x43   (0xE01)
  ld    b,   0x0                                                                   // 0x44   (0xE10)

//
// Clears 8 nibbles at a time until b + 0xF becomes 0
// Starts at {A, 8'h0}
// Returns
//
clear_8_starting_at_a_xp:
  ld    xp,  a                                                                     // 0x45   (0xE80)
  ld    x,   0x0                                                                   // 0x46   (0xB00)

//
// Clears 8 nibbles at a time until b + 0xF becomes 0
// Returns
//
loop_clear_8:
  lbpx  mx,  0x0                                                                   // 0x47   (0x900)
  lbpx  mx,  0x0                                                                   // 0x48   (0x900)
  lbpx  mx,  0x0                                                                   // 0x49   (0x900)
  lbpx  mx,  0x0                                                                   // 0x4A   (0x900)
  lbpx  mx,  0x0                                                                   // 0x4B   (0x900)
  lbpx  mx,  0x0                                                                   // 0x4C   (0x900)
  lbpx  mx,  0x0                                                                   // 0x4D   (0x900)
  lbpx  mx,  0x0                                                                   // 0x4E   (0x900)
  add   b,   0xF                                                                   // 0x4F   (0xC1F)
  jp    nz,  loop_clear_8                                                          // 0x50   (0x747)
  ret                                                                              // 0x51   (0xFDF)

label_13:
  pset  0x4                                                                        // 0x52   (0xE44)
  call  label_145                                                                  // 0x53   (0x486)

calz_copy_buf_and_render_misc:
  pset  0x4                                                                        // 0x54   (0xE44)
  call  copy_buf_and_render_misc                                                   // 0x55   (0x400)

//
// Copies video buffer data from {1, 0x02B, 0x02A} to VRAM at 0xE00/0xE80
// Returns
//
copy_video_buf_to_vram:
  calz  zero_a_xp                                                                  // 0x56   (0x5EF)
  ld    x,   0x2A                                                                  // 0x57   (0xB2A)
  ld    yl,  mx                                                                    // 0x58   (0xE9A)
  ldpx  a,   a                                                                     // 0x59   (0xEE0)
  ld    yh,  mx                                                                    // 0x5A   (0xE96)
  ld    a,   0x1                                                                   // 0x5B   (0xE01)
  // Set Y to {1, 0x02B, 0x02A}
  ld    yp,  a                                                                     // 0x5C   (0xE90)
  ld    a,   0xE                                                                   // 0x5D   (0xE0E)
  ld    xp,  a                                                                     // 0x5E   (0xE80)
  // Set X to 0xE00
  // Start of video RAM
  ld    x,   0x0                                                                   // 0x5F   (0xB00)
  // Increments X to 0xE10 and Y to 
  call  copy_16_mx_my_ret                                                          // 0x60   (0x48D)
  // Clear carry (it shouldn't have been set?)
  rst   f,   0xE                                                                   // 0x61   (0xF5E)
  // Assuming we started at 0x100, we'd be at 0x110, then offset to 0x180
  adc   yh,  0x7                                                                   // 0x62   (0xA27)
  // Set X to 0xE80 (second video RAM bank)
  ld    x,   0x80                                                                  // 0x63   (0xB80)
  call  copy_16_mx_my_ret                                                          // 0x64   (0x48D)
  // Clear carry
  rst   f,   0xE                                                                   // 0x65   (0xF5E)
  // Assuming we started at 0x100, we'd be at 0x190, then offset to 0x110
  adc   yh,  0x8                                                                   // 0x66   (0xA28)
  // Set X to 0xE12 (a bit offset from last first video bank write)
  ld    x,   0x12                                                                  // 0x67   (0xB12)
  call  copy_16_mx_my_ret                                                          // 0x68   (0x48D)
  // Clear carry
  rst   f,   0xE                                                                   // 0x69   (0xF5E)
  // Assuming we started at 0x100, we'd be at 0x120, then offset to 0x190
  adc   yh,  0x7                                                                   // 0x6A   (0xA27)
  // Set X to 0xE92
  ld    x,   0x92                                                                  // 0x6B   (0xB92)
  call  copy_16_mx_my_ret                                                          // 0x6C   (0x48D)
  // Clear carry
  rst   f,   0xE                                                                   // 0x6D   (0xF5E)
  
  // Assuming we started at 0x100, we'd be at 0x1A0, then offset to 0x120
  adc   yh,  0x8                                                                   // 0x6E   (0xA28)
  // Set X to 0xE48
  ld    x,   0x48                                                                  // 0x6F   (0xB48)
  // Set carry
  set   f,   0x1                                                                   // 0x70   (0xF41)
  call  copy_10_mx_my_offset_ret                                                   // 0x71   (0x49F)
  ld    x,   0x3E                                                                  // 0x72   (0xB3E)
  set   f,   0x1                                                                   // 0x73   (0xF41)
  call  copy_6_mx_my_offset_ret                                                    // 0x74   (0x4A7)
  rst   f,   0xE                                                                   // 0x75   (0xF5E)
  adc   yh,  0x7                                                                   // 0x76   (0xA27)
  ld    x,   0xC8                                                                  // 0x77   (0xBC8)
  set   f,   0x1                                                                   // 0x78   (0xF41)
  call  copy_10_mx_my_offset_ret                                                   // 0x79   (0x49F)
  ld    x,   0xBE                                                                  // 0x7A   (0xBBE)
  set   f,   0x1                                                                   // 0x7B   (0xF41)
  call  copy_6_mx_my_offset_ret                                                    // 0x7C   (0x4A7)
  rst   f,   0xE                                                                   // 0x7D   (0xF5E)
  adc   yh,  0x8                                                                   // 0x7E   (0xA28)
  ld    x,   0x36                                                                  // 0x7F   (0xB36)
  set   f,   0x1                                                                   // 0x80   (0xF41)
  call  copy_8_mx_my_offset_ret                                                    // 0x81   (0x4A3)
  ld    x,   0x2E                                                                  // 0x82   (0xB2E)
  set   f,   0x1                                                                   // 0x83   (0xF41)
  call  copy_8_mx_my_offset_ret                                                    // 0x84   (0x4A3)
  rst   f,   0xE                                                                   // 0x85   (0xF5E)
  adc   yh,  0x7                                                                   // 0x86   (0xA27)
  ld    x,   0xB6                                                                  // 0x87   (0xBB6)
  set   f,   0x1                                                                   // 0x88   (0xF41)
  call  copy_8_mx_my_offset_ret                                                    // 0x89   (0x4A3)
  ld    x,   0xAE                                                                  // 0x8A   (0xBAE)
  set   f,   0x1                                                                   // 0x8B   (0xF41)
  jp    copy_8_mx_my_offset_ret                                                    // 0x8C   (0xA3)

copy_16_mx_my_ret:
  call  copy_8_mx_my_ret                                                           // 0x8D   (0x48F)
  ldpx  a,   a                                                                     // 0x8E   (0xEE0)

//
// Copy 8 nibbles from MX, MX + 7 to MY, MY + 7
// Returns
//
copy_8_mx_my_ret:
  ldpy  mx,  my                                                                    // 0x8F   (0xEFB)
  ldpx  a,   a                                                                     // 0x90   (0xEE0)
  ldpy  mx,  my                                                                    // 0x91   (0xEFB)
  ldpx  a,   a                                                                     // 0x92   (0xEE0)
  ldpy  mx,  my                                                                    // 0x93   (0xEFB)
  ldpx  a,   a                                                                     // 0x94   (0xEE0)
  ldpy  mx,  my                                                                    // 0x95   (0xEFB)
  ldpx  a,   a                                                                     // 0x96   (0xEE0)
  ldpy  mx,  my                                                                    // 0x97   (0xEFB)
  ldpx  a,   a                                                                     // 0x98   (0xEE0)

//
// Copy three nibbles from MX, MX + 2 to MY, MY + 2
// Returns
//
copy_3_mx_my_ret:
  ldpy  mx,  my                                                                    // 0x99   (0xEFB)
  ldpx  a,   a                                                                     // 0x9A   (0xEE0)

//
// Copy two nibbles from MX, MX + 1 to MY, MY + 1
// Returns
//
copy_2_mx_my_ret:
  ldpy  mx,  my                                                                    // 0x9B   (0xEFB)
  ldpx  a,   a                                                                     // 0x9C   (0xEE0)
  ldpy  mx,  my                                                                    // 0x9D   (0xEFB)
  ret                                                                              // 0x9E   (0xFDF)

//
// Copies 10 nibbles from MX, MX + 9 to MY, MY + 9
// Every two copies offsets XL by 0xC
// Returns
//
copy_10_mx_my_offset_ret:
  ldpy  mx,  my                                                                    // 0x9F   (0xEFB)
  ldpx  a,   a                                                                     // 0xA0   (0xEE0)
  ldpy  mx,  my                                                                    // 0xA1   (0xEFB)
  adc   xl,  0xC                                                                   // 0xA2   (0xA1C)

//
// Copies 8 nibbles from MX, MX + 7 to MY, MY + 7
// Every two copies offsets XL by 0xC
// Returns
//
copy_8_mx_my_offset_ret:
  ldpy  mx,  my                                                                    // 0xA3   (0xEFB)
  ldpx  a,   a                                                                     // 0xA4   (0xEE0)
  ldpy  mx,  my                                                                    // 0xA5   (0xEFB)
  adc   xl,  0xC                                                                   // 0xA6   (0xA1C)

//
// Copies 6 nibbles from MX, MX + 5 to MY, MY + 5
// Every two copies offsets XL by 0xC
// Returns
//
copy_6_mx_my_offset_ret:
  ldpy  mx,  my                                                                    // 0xA7   (0xEFB)
  ldpx  a,   a                                                                     // 0xA8   (0xEE0)
  ldpy  mx,  my                                                                    // 0xA9   (0xEFB)
  adc   xl,  0xC                                                                   // 0xAA   (0xA1C)
  ldpy  mx,  my                                                                    // 0xAB   (0xEFB)
  ldpx  a,   a                                                                     // 0xAC   (0xEE0)
  ldpy  mx,  my                                                                    // 0xAD   (0xEFB)
  adc   xl,  0xC                                                                   // 0xAE   (0xA1C)
  ldpy  mx,  my                                                                    // 0xAF   (0xEFB)
  ldpx  a,   a                                                                     // 0xB0   (0xEE0)
  ldpy  mx,  my                                                                    // 0xB1   (0xEFB)
  ret                                                                              // 0xB2   (0xFDF)

//
// Check if 0x04A highest bit is set. If so, zero will be unset, otherwise set
// Returns
//
check_0x04A_highbit:
  calz  zero_a_xp                                                                  // 0xB3   (0x5EF)
  // Set X to 0x04A
  ld    x,   0x4A                                                                  // 0xB4   (0xB4A)
  fan   mx,  0x8                                                                   // 0xB5   (0xDA8)
  ret                                                                              // 0xB6   (0xFDF)

label_24:
  calz  zero_b_xp                                                                  // 0xB7   (0x5F2)
  jp    if_0x7B_set_clear_0x32_store_yhl                                           // 0xB8   (0xBF)
  
// TODO: I don't think this is reachable
  calz  zero_a_xp                                                                  // 0xB9   (0x5EF)
  jp    if_0x7B_set_clear_0x32_store_yhl                                           // 0xBA   (0xBF)

label_25:
  ld    y,   0x94                                                                  // 0xBB   (0x894)

//
// Checks if 0x07B is set, if so:
// Clears 0x032, copies YHL to 0x036/7
// Sets 0x058 to A, 0x059 to 0xF
// 0x07D is disabled during this operation
// Returns
//
if_0x7B_set_clear_0x32_store_yhl_set_0x059_to_0xF:
  ld    b,   0xF                                                                   // 0xBC   (0xE1F)
  ld    a,   0x0                                                                   // 0xBD   (0xE00)
  ld    xp,  a                                                                     // 0xBE   (0xE80)

//
// Checks if 0x?7B is set, if so:
// Clears 0x?32, copies YHL to 0x?36/7
// Sets 0x?58/9 to A, B
// 0x07D is disabled during this operation
// Returns
//
if_0x7B_set_clear_0x32_store_yhl:
  // X is 0x?7B
  ld    x,   0x7B                                                                  // 0xBF   (0xB7B)
  cp    mx,  0x0                                                                   // 0xC0   (0xDE0)
  // If 0x?7B is 0, return
  jp    z,   if_0x7B_set_clear_0x32_store_yhl_ret                                  // 0xC1   (0x6CD)

//
// Clears 0x?32, copies YHL to 0x?36/7
// Sets 0x?58/9 to A, B
// 0x07D is disabled during this operation
// Returns
//
clear_0x32_store_yhl:
  // X is 0x?32
  ld    x,   0x32                                                                  // 0xC2   (0xB32)
  calz  clear_0x07D                                                                // 0xC3   (0x512)
  // Set 0x?32 to 0
  lbpx  mx,  0x0                                                                   // 0xC4   (0x900)
  // X is 0x?36
  ld    x,   0x36                                                                  // 0xC5   (0xB36)
  // Set 0?036 to yl
  ld    mx,  yl                                                                    // 0xC6   (0xEBA)
  ldpx  a,   a                                                                     // 0xC7   (0xEE0)
  // Set 0x?37 to yh
  ld    mx,  yh                                                                    // 0xC8   (0xEB6)
  // X is 0x?58
  ld    x,   0x58                                                                  // 0xC9   (0xB58)
  // Set 0x?58 to A
  ldpx  mx,  a                                                                     // 0xCA   (0xEE8)
  // Set 0x?59 to B
  ld    mx,  b                                                                     // 0xCB   (0xEC9)
  calz  set_f_0x07D                                                                // 0xCC   (0x509)

if_0x7B_set_clear_0x32_store_yhl_ret:
  ret                                                                              // 0xCD   (0xFDF)

label_30:
  ld    a,   0x0                                                                   // 0xCE   (0xE00)
  ld    xp,  a                                                                     // 0xCF   (0xE80)
  ld    x,   0x2A                                                                  // 0xD0   (0xB2A)
  lbpx  mx,  0x40                                                                  // 0xD1   (0x940)
  ld    x,   0x3A                                                                  // 0xD2   (0xB3A)
  ret                                                                              // 0xD3   (0xFDF)

label_31:
  calz  clear_0x07D                                                                // 0xD4   (0x512)
  ldpy  a,   my                                                                    // 0xD5   (0xEF3)
  jp    label_33                                                                   // 0xD6   (0xDB)

label_32:
  calz  clear_0x07D                                                                // 0xD7   (0x512)
  ldpy  a,   my                                                                    // 0xD8   (0xEF3)
  or    a,   my                                                                    // 0xD9   (0xAD3)
  ldpy  a,   a                                                                     // 0xDA   (0xEF0)

label_33:
  or    a,   my                                                                    // 0xDB   (0xAD3)
  calz  set_f_0x07D                                                                // 0xDC   (0x509)
  ret                                                                              // 0xDD   (0xFDF)

label_34:
  calz  label_30                                                                   // 0xDE   (0x5CE)
  lbpx  mx,  0x40                                                                  // 0xDF   (0x940)
  pset  0x7                                                                        // 0xE0   (0xE47)
  jp    label_233                                                                  // 0xE1   (0x92)

label_35:
  ld    x,   0x12                                                                  // 0xE2   (0xB12)
  set   f,   0x4                                                                   // 0xE3   (0xF44)

label_36:
  add   mx,  0x1                                                                   // 0xE4   (0xC21)
  ldpx  a,   a                                                                     // 0xE5   (0xEE0)
  adc   mx,  0x0                                                                   // 0xE6   (0xC60)
  cp    mx,  0x6                                                                   // 0xE7   (0xDE6)
  jp    c,   label_37                                                              // 0xE8   (0x2EA)
  ld    mx,  0x0                                                                   // 0xE9   (0xE20)

label_37:
  rst   f,   0xB                                                                   // 0xEA   (0xF5B)
  ret                                                                              // 0xEB   (0xFDF)

label_38:
  ld    a,   0x0                                                                   // 0xEC   (0xE00)

label_39:
  pset  0x7                                                                        // 0xED   (0xE47)
  jp    label_238                                                                  // 0xEE   (0xC0)

// 
// Zeros A and XP, then returns
// 
zero_a_xp:
  ld    a,   0x0                                                                   // 0xEF   (0xE00)
  ld    xp,  a                                                                     // 0xF0   (0xE80)
  ret                                                                              // 0xF1   (0xFDF)

// 
// Zeros B and XP, then returns
// 
zero_b_xp:
  ld    b,   0x0                                                                   // 0xF2   (0xE10)
  ld    xp,  b                                                                     // 0xF3   (0xE81)
  ret                                                                              // 0xF4   (0xFDF)

// 
// Sets A and XP to 1, then returns
// 
one_a_xp:
  ld    a,   0x1                                                                   // 0xF5   (0xE01)
  ld    xp,  a                                                                     // 0xF6   (0xE80)
  ret                                                                              // 0xF7   (0xFDF)

//
// Using the provided XP, checks if 0xX5D == 1, then returns
//
check_0xX5D_is_1:
  ld    x,   0x5D                                                                  // 0xF8   (0xB5D)
  cp    mx,  0x1                                                                   // 0xF9   (0xDE1)
  ret                                                                              // 0xFA   (0xFDF)

//
// Zeros A and XP
// Checks if high bit of 0x048 is set (zero high if not)
// Returns
// 
zero_a_xp_and_bit_high_at_0x048:
  ld    a,   0x0                                                                   // 0xFB   (0xE00)
  ld    xp,  a                                                                     // 0xFC   (0xE80)

//
// Checks if high bit of 0x048 is set (zero high if not), then returns
//
bit_high_at_0x048:
  ld    x,   0x48                                                                  // 0xFD   (0xB48)
  fan   mx,  0x8                                                                   // 0xFE   (0xDA8)
  ret                                                                              // 0xFF   (0xFDF)
  
// Vector table
  jp    reset_vector                                                               // 0x100  (0x10)
  jp    generic_int                                                                // 0x101  (0x16)
  jp    clock_timer_int                                                            // 0x102  (0x1D)
  jp    generic_int                                                                // 0x103  (0x16)
  jp    generic_int                                                                // 0x104  (0x16)
  jp    generic_int                                                                // 0x105  (0x16)
  jp    generic_int                                                                // 0x106  (0x16)
  jp    generic_int                                                                // 0x107  (0x16)
  jp    generic_int                                                                // 0x108  (0x16)
  jp    generic_int                                                                // 0x109  (0x16)
  jp    generic_int                                                                // 0x10A  (0x16)
  jp    generic_int                                                                // 0x10B  (0x16)
  jp    prog_timer_int                                                             // 0x10C  (0x6F)
  jp    generic_int                                                                // 0x10D  (0x16)
  jp    generic_int                                                                // 0x10E  (0x16)
  jp    generic_int                                                                // 0x10F  (0x16)

reset_vector:
  rst   f,   0x0                                                                   // 0x110  (0xF50)
  ld    a,   0xF                                                                   // 0x111  (0xE0F)
  ld    sph, a                                                                     // 0x112  (0xFE0)
  ld    spl, a                                                                     // 0x113  (0xFF0)
  pset  0x2                                                                        // 0x114  (0xE42)
  jp    reset_vect_cont                                                            // 0x115  (0x2A)

generic_int:
  push  f                                                                          // 0x116  (0xFCA)
  push  a                                                                          // 0x117  (0xFC0)
  push  b                                                                          // 0x118  (0xFC1)
  push  xp                                                                         // 0x119  (0xFC4)
  push  xh                                                                         // 0x11A  (0xFC5)
  push  xl                                                                         // 0x11B  (0xFC6)
  jp    int_restore_ret                                                            // 0x11C  (0x5B)

clock_timer_int:
  push  f                                                                          // 0x11D  (0xFCA)
  push  a                                                                          // 0x11E  (0xFC0)
  push  b                                                                          // 0x11F  (0xFC1)
  push  xp                                                                         // 0x120  (0xFC4)
  push  xh                                                                         // 0x121  (0xFC5)
  push  xl                                                                         // 0x122  (0xFC6)
  // Disable decimal
  rst   f,   0xB                                                                   // 0x123  (0xF5B)
  ld    a,   0xF                                                                   // 0x124  (0xE0F)
  ld    xp,  a                                                                     // 0x125  (0xE80)
  ld    x,   0x0                                                                   // 0x126  (0xB00)
  // a = 0xF00. Clear clock timer factor flag
  ld    a,   mx                                                                    // 0x127  (0xEC2)
  ld    x,   0x76                                                                  // 0x128  (0xB76)
  
  // Set 0xF77-6 to 0x01. Reset watchdog timer
  lbpx  mx,  0x1                                                                   // 0x129  (0x901)
  // Set 0xF79-8 to 0x21
  // 0xF78: Start progamable timer
  // 0xF79: Choose prog timer clock interval 256Hz
  lbpx  mx,  0x21                                                                  // 0x12A  (0x921)
  ld    x,   0x12                                                                  // 0x12B  (0xB12)
  // Set 0xF12 to 1. Enable prog timer interrupt mask
  ld    mx,  0x1                                                                   // 0x12C  (0xE21)
  ld    a,   0x0                                                                   // 0x12D  (0xE00)
  ld    xp,  a                                                                     // 0x12E  (0xE80)
  ld    x,   0x57                                                                  // 0x12F  (0xB57)
  // Check if 0x057 is 0
  cp    mx,  0x0                                                                   // 0x130  (0xDE0)
  // If so, skip add
  jp    z,   clock_timer_int_skip_add                                              // 0x131  (0x633)
  // Otherwise, add F to 0x057
  add   mx,  0xF                                                                   // 0x132  (0xC2F)

clock_timer_int_skip_add:
  ld    x,   0x3C                                                                  // 0x133  (0xB3C)
  // Check if 0x03C is 0
  cp    mx,  0x0                                                                   // 0x134  (0xDE0)
  // If so, jump
  jp    z,   label_52                                                              // 0x135  (0x64A)
  // Enable decimal
  set   f,   0x4                                                                   // 0x136  (0xF44)
  ld    x,   0x2E                                                                  // 0x137  (0xB2E)
  // Set 0x02E to 1
  ld    mx,  0x1                                                                   // 0x138  (0xE21)
  ld    x,   0x10                                                                  // 0x139  (0xB10)
  // Add 1 to 0x010
  // Looks like this is incrementing the second
  add   mx,  0x1                                                                   // 0x13A  (0xC21)
  // Increment X
  ldpx  a,   a                                                                     // 0x13B  (0xEE0)
  // Add carry from 0x010 add to 0x011
  // Second digit of second
  adc   mx,  0x0                                                                   // 0x13C  (0xC60)
  // Check if 0x011 is 6
  cp    mx,  0x6                                                                   // 0x13D  (0xDE6)
  // If so, jump
  jp    c,   label_51                                                              // 0x13E  (0x249)
  // Set 0x011 to 0
  ldpx  mx,  0x0                                                                   // 0x13F  (0xE60)
  calz  label_36                                                                   // 0x140  (0x5E4)
  jp    c,   label_50                                                              // 0x141  (0x247)
  
  // TODO: Unused?
  ld    x,   0x14                                                                  // 0x142  (0xB14)
  ldpx  a,   mx                                                                    // 0x143  (0xEE2)
  ldpx  b,   mx                                                                    // 0x144  (0xEE6)
  ld    x,   0x14                                                                  // 0x145  (0xB14)
  call  label_67                                                                   // 0x146  (0x4F4)

label_50:
  pset  0xC                                                                        // 0x147  (0xE4C)
  call  label_312                                                                  // 0x148  (0x47A)

label_51:
  // Clear decimal 
  rst   f,   0xB                                                                   // 0x149  (0xF5B)

label_52:
  ld    a,   0x0                                                                   // 0x14A  (0xE00)
  ld    xp,  a                                                                     // 0x14B  (0xE80)
  // X is 0x02F
  ld    x,   0x2F                                                                  // 0x14C  (0xB2F)
  add   mx,  0x1                                                                   // 0x14D  (0xC21)
  ldpx  a,   a                                                                     // 0x14E  (0xEE0)
  // If 0x02F carried, add 1 to 0x030
  acpx  mx,  a                                                                     // 0x14F  (0xF28)
  // If 0x030 carried, add 1 to 0x031
  adc   mx,  0x0                                                                   // 0x150  (0xC60)
  jp    nc,  int_restore_ret                                                       // 0x151  (0x35B)
  ld    a,   0xF                                                                   // 0x152  (0xE0F)
  ld    xp,  a                                                                     // 0x153  (0xE80)
  // X is 0xF70
  ld    x,   0x70                                                                  // 0x154  (0xB70)
  // AND with CPU voltage switch
  fan   mx,  0x3                                                                   // 0x155  (0xDA3)
  // If voltage is < 3.1V, jump
  jp    z,   int_restore_ret                                                       // 0x156  (0x65B)
  call  check_svd_voltage                                                          // 0x157  (0x4E5)
  // If voltage is normal, jump
  jp    z,   int_restore_ret                                                       // 0x158  (0x65B)
  ld    x,   0x70                                                                  // 0x159  (0xB70)
  // Clear all CPU voltage settings
  ld    mx,  0x0                                                                   // 0x15A  (0xE20)

int_restore_ret:
  ld    a,   0x0                                                                   // 0x15B  (0xE00)
  ld    xp,  a                                                                     // 0x15C  (0xE80)
  ld    x,   0x7D                                                                  // 0x15D  (0xB7D)
  // Check if 0x07D is 0
  cp    mx,  0x0                                                                   // 0x15E  (0xDE0)
  // If so, jump, and don't re-enable interrupts
  jp    z,   gen_int_dis_int                                                       // 0x15F  (0x668)
  pop   xl                                                                         // 0x160  (0xFD6)
  pop   xh                                                                         // 0x161  (0xFD5)
  pop   xp                                                                         // 0x162  (0xFD4)
  pop   b                                                                          // 0x163  (0xFD1)
  pop   a                                                                          // 0x164  (0xFD0)
  pop   f                                                                          // 0x165  (0xFDA)
  // Enable interrupts
  set   f,   0x8                                                                   // 0x166  (0xF48)
  ret                                                                              // 0x167  (0xFDF)

gen_int_dis_int:
  pop   xl                                                                         // 0x168  (0xFD6)
  pop   xh                                                                         // 0x169  (0xFD5)
  pop   xp                                                                         // 0x16A  (0xFD4)
  pop   b                                                                          // 0x16B  (0xFD1)
  pop   a                                                                          // 0x16C  (0xFD0)
  pop   f                                                                          // 0x16D  (0xFDA)
  ret                                                                              // 0x16E  (0xFDF)

prog_timer_int:
  push  f                                                                          // 0x16F  (0xFCA)
  push  a                                                                          // 0x170  (0xFC0)
  push  b                                                                          // 0x171  (0xFC1)
  push  xp                                                                         // 0x172  (0xFC4)
  push  xh                                                                         // 0x173  (0xFC5)
  push  xl                                                                         // 0x174  (0xFC6)
  rst   f,   0xB                                                                   // 0x175  (0xF5B)
  call  label_59                                                                   // 0x176  (0x4A0)
  ld    a,   0xF                                                                   // 0x177  (0xE0F)
  ld    xp,  a                                                                     // 0x178  (0xE80)
  ld    x,   0x2                                                                   // 0x179  (0xB02)
  ld    a,   mx                                                                    // 0x17A  (0xEC2)
  ld    x,   0x40                                                                  // 0x17B  (0xB40)
  ld    b,   mx                                                                    // 0x17C  (0xEC6)
  xor   b,   0xF                                                                   // 0x17D  (0xD1F)
  and   b,   0x7                                                                   // 0x17E  (0xC97)
  ld    a,   0x0                                                                   // 0x17F  (0xE00)
  ld    xp,  a                                                                     // 0x180  (0xE80)
  ld    x,   0x5A                                                                  // 0x181  (0xB5A)
  add   mx,  0x1                                                                   // 0x182  (0xC21)
  ld    x,   0x22                                                                  // 0x183  (0xB22)
  add   mx,  0xF                                                                   // 0x184  (0xC2F)
  ldpx  a,   a                                                                     // 0x185  (0xEE0)
  adc   mx,  0xF                                                                   // 0x186  (0xC6F)
  jp    c,   label_56                                                              // 0x187  (0x28A)
  ld    x,   0x22                                                                  // 0x188  (0xB22)
  lbpx  mx,  0x0                                                                   // 0x189  (0x900)

label_56:
  ld    x,   0x26                                                                  // 0x18A  (0xB26)
  ld    a,   mx                                                                    // 0x18B  (0xEC2)
  ldpx  mx,  b                                                                     // 0x18C  (0xEE9)
  xor   a,   b                                                                     // 0x18D  (0xAE1)
  and   a,   b                                                                     // 0x18E  (0xAC1)
  or    mx,  a                                                                     // 0x18F  (0xAD8)
  ld    x,   0x3D                                                                  // 0x190  (0xB3D)
  cp    mx,  b                                                                     // 0x191  (0xF09)
  jp    z,   label_57                                                              // 0x192  (0x697)
  ld    mx,  b                                                                     // 0x193  (0xEC9)
  ld    x,   0x3E                                                                  // 0x194  (0xB3E)
  ld    mx,  0x0                                                                   // 0x195  (0xE20)
  jp    label_58                                                                   // 0x196  (0x9F)

label_57:
  ld    x,   0x3E                                                                  // 0x197  (0xB3E)
  add   mx,  0x1                                                                   // 0x198  (0xC21)
  jp    nz,  label_58                                                              // 0x199  (0x79F)
  ld    mx,  0x8                                                                   // 0x19A  (0xE28)
  ld    x,   0x3F                                                                  // 0x19B  (0xB3F)
  and   b,   mx                                                                    // 0x19C  (0xAC6)
  ld    x,   0x27                                                                  // 0x19D  (0xB27)
  or    mx,  b                                                                     // 0x19E  (0xAD9)

label_58:
  jp    int_restore_ret                                                            // 0x19F  (0x5B)

label_59:
  ld    a,   0x0                                                                   // 0x1A0  (0xE00)
  ld    xp,  a                                                                     // 0x1A1  (0xE80)
  ld    x,   0x32                                                                  // 0x1A2  (0xB32)
  add   mx,  0xF                                                                   // 0x1A3  (0xC2F)
  ldpx  a,   a                                                                     // 0x1A4  (0xEE0)
  adc   mx,  0xF                                                                   // 0x1A5  (0xC6F)
  jp    nc,  label_60                                                              // 0x1A6  (0x3AB)
  ld    x,   0x34                                                                  // 0x1A7  (0xB34)
  fan   mx,  0x8                                                                   // 0x1A8  (0xDA8)
  jp    nz,  label_62                                                              // 0x1A9  (0x7D7)
  ret                                                                              // 0x1AA  (0xFDF)

label_60:
  ld    x,   0x36                                                                  // 0x1AB  (0xB36)
  ld    a,   mx                                                                    // 0x1AC  (0xEC2)
  add   mx,  0x2                                                                   // 0x1AD  (0xC22)
  ldpx  a,   a                                                                     // 0x1AE  (0xEE0)
  ld    b,   mx                                                                    // 0x1AF  (0xEC6)
  adc   mx,  0x0                                                                   // 0x1B0  (0xC60)
  ld    x,   0x32                                                                  // 0x1B1  (0xB32)
  pset  0xE                                                                        // 0x1B2  (0xE4E)
  call  jp_table_0xE00_2                                                           // 0x1B3  (0x47C)
  cp    xl,  0x6                                                                   // 0x1B4  (0xA56)
  jp    z,   label_61                                                              // 0x1B5  (0x6C1)
  ld    x,   0x59                                                                  // 0x1B6  (0xB59)
  cp    mx,  0xF                                                                   // 0x1B7  (0xDEF)
  jp    z,   label_61                                                              // 0x1B8  (0x6C1)
  ld    x,   0x58                                                                  // 0x1B9  (0xB58)
  add   mx,  0xF                                                                   // 0x1BA  (0xC2F)
  ldpx  a,   a                                                                     // 0x1BB  (0xEE0)
  adc   mx,  0xF                                                                   // 0x1BC  (0xC6F)
  jp    c,   label_61                                                              // 0x1BD  (0x2C1)
  ld    x,   0x36                                                                  // 0x1BE  (0xB36)
  lbpx  mx,  0x7D                                                                  // 0x1BF  (0x97D)
  jp    label_60                                                                   // 0x1C0  (0xAB)

label_61:
  ld    x,   0x34                                                                  // 0x1C1  (0xB34)
  fan   mx,  0x8                                                                   // 0x1C2  (0xDA8)
  jp    nz,  label_62                                                              // 0x1C3  (0x7D7)
  ld    x,   0x38                                                                  // 0x1C4  (0xB38)
  lbpx  mx,  0x58                                                                  // 0x1C5  (0x958)
  ld    a,   0xF                                                                   // 0x1C6  (0xE0F)
  ld    xp,  a                                                                     // 0x1C7  (0xE80)
  ld    x,   0x71                                                                  // 0x1C8  (0xB71)
  or    mx,  0x1                                                                   // 0x1C9  (0xCE1)
  push  xp                                                                         // 0x1CA  (0xFC4)
  ld    a,   0x0                                                                   // 0x1CB  (0xE00)
  ld    xp,  a                                                                     // 0x1CC  (0xE80)
  ld    x,   0x34                                                                  // 0x1CD  (0xB34)
  ldpx  a,   mx                                                                    // 0x1CE  (0xEE2)
  ld    b,   mx                                                                    // 0x1CF  (0xEC6)
  pop   xp                                                                         // 0x1D0  (0xFD4)
  ld    x,   0x74                                                                  // 0x1D1  (0xB74)
  ldpx  mx,  a                                                                     // 0x1D2  (0xEE8)
  ld    mx,  b                                                                     // 0x1D3  (0xEC9)
  ld    x,   0x54                                                                  // 0x1D4  (0xB54)
  and   mx,  0x7                                                                   // 0x1D5  (0xCA7)
  ret                                                                              // 0x1D6  (0xFDF)

label_62:
  ld    x,   0x38                                                                  // 0x1D7  (0xB38)
  add   mx,  0xF                                                                   // 0x1D8  (0xC2F)
  ldpx  a,   a                                                                     // 0x1D9  (0xEE0)
  adc   mx,  0xF                                                                   // 0x1DA  (0xC6F)
  ld    a,   0xF                                                                   // 0x1DB  (0xE0F)
  ld    xp,  a                                                                     // 0x1DC  (0xE80)
  jp    c,   label_63                                                              // 0x1DD  (0x2E0)
  ld    x,   0x71                                                                  // 0x1DE  (0xB71)
  and   mx,  0xE                                                                   // 0x1DF  (0xCAE)

label_63:
  ld    x,   0x54                                                                  // 0x1E0  (0xB54)
  or    mx,  0x8                                                                   // 0x1E1  (0xCE8)
  ret                                                                              // 0x1E2  (0xFDF)

//
// Check SVD voltage
// Sets Zero if voltage is normal
// Sets XP to F
// Returns
//
check_svd_voltage_set_xp_f:
  ld    a,   0xF                                                                   // 0x1E3  (0xE0F)
  ld    xp,  a                                                                     // 0x1E4  (0xE80)

//
// Check SVD voltage
// Sets Zero if voltage is normal
// Returns
//
check_svd_voltage:
  // All paths set XP to 0xF
  // X is 0xF73
  ld    x,   0x73                                                                  // 0x1E5  (0xB73)
  // Turn on SVD circuit at the 2 setting (-3.1 V)
  ld    mx,  0x6                                                                   // 0x1E6  (0xE26)
  nop5                                                                             // 0x1E7  (0xFFB)
  // Read the current voltage status
  ld    a,   mx                                                                    // 0x1E8  (0xEC2)
  // Disable the SVD circuit
  ld    mx,  0x0                                                                   // 0x1E9  (0xE20)
  // Check if voltage is low (0x8 would be set)
  and   a,   0x8                                                                   // 0x1EA  (0xC88)
  ret                                                                              // 0x1EB  (0xFDF)

label_66:
  ld    x,   0x75                                                                  // 0x1EC  (0xB75)
  ldpx  mx,  0x0                                                                   // 0x1ED  (0xE60)
  ldpx  mx,  a                                                                     // 0x1EE  (0xEE8)
  ldpx  mx,  b                                                                     // 0x1EF  (0xEE9)
  ld    x,   0x57                                                                  // 0x1F0  (0xB57)
  ldpx  mx,  b                                                                     // 0x1F1  (0xEE9)
  calz  copy_0x026_7_to_8_9                                                        // 0x1F2  (0x521)
  ret                                                                              // 0x1F3  (0xFDF)

label_67:
  add   a,   0x1                                                                   // 0x1F4  (0xC01)
  adc   b,   0x0                                                                   // 0x1F5  (0xC50)
  cp    b,   0x1                                                                   // 0x1F6  (0xDD1)
  jp    c,   label_69                                                              // 0x1F7  (0x2FD)
  jp    nz,  label_68                                                              // 0x1F8  (0x7FB)
  cp    a,   0x8                                                                   // 0x1F9  (0xDC8)
  jp    c,   label_69                                                              // 0x1FA  (0x2FD)

label_68:
  ld    a,   0x0                                                                   // 0x1FB  (0xE00)
  ld    b,   0x0                                                                   // 0x1FC  (0xE10)

label_69:
  ldpx  mx,  a                                                                     // 0x1FD  (0xEE8)
  ldpx  mx,  b                                                                     // 0x1FE  (0xEE9)
  ret                                                                              // 0x1FF  (0xFDF)

label_70:
  calz  copy_video_buf_to_vram                                                     // 0x200  (0x556)
  calz  copy_0x026_7_to_8_9                                                        // 0x201  (0x521)
  cp    a,   0x5                                                                   // 0x202  (0xDC5)
  jp    z,   label_71                                                              // 0x203  (0x606)
  fan   b,   0x1                                                                   // 0x204  (0xD91)
  ret                                                                              // 0x205  (0xFDF)

label_71:
  calz  clear_0x07D                                                                // 0x206  (0x512)
  calz  zero_a_xp                                                                  // 0x207  (0x5EF)
  ld    a,   0x2                                                                   // 0x208  (0xE02)
  ld    yp,  a                                                                     // 0x209  (0xE90)
  // X is 0x010
  ld    x,   0x10                                                                  // 0x20A  (0xB10)
  // Y is 0x272
  ld    y,   0x72                                                                  // 0x20B  (0x872)
  call  springboard_copy_6_mx_my                                                   // 0x20C  (0x427)
  // Clear all flags
  rst   f,   0x0                                                                   // 0x20D  (0xF50)
  ld    a,   0xF                                                                   // 0x20E  (0xE0F)
  ld    sph, a                                                                     // 0x20F  (0xFE0)
  ld    spl, a                                                                     // 0x210  (0xFF0)
  // Set SP to 0xFF
  call  springboard_set_init_mem_and_int                                           // 0x211  (0x442)
  ld    a,   0x0                                                                   // 0x212  (0xE00)
  ld    yp,  a                                                                     // 0x213  (0xE90)
  ld    a,   0x2                                                                   // 0x214  (0xE02)
  ld    xp,  a                                                                     // 0x215  (0xE80)
  // Y is 0x010
  ld    y,   0x10                                                                  // 0x216  (0x810)
  // X is 0x272
  ld    x,   0x72                                                                  // 0x217  (0xB72)
  // Copy 6 nibbles from 0x272 to 0x010
  call  springboard_copy_6_mx_my                                                   // 0x218  (0x427)
  calz  set_f_0x07D                                                                // 0x219  (0x509)
  // Y is 0x080
  ld    y,   0x80                                                                  // 0x21A  (0x880)
  // 0x07B was not touched by above intialization
  calz  if_0x7B_set_clear_0x32_store_yhl_set_0x059_to_0xF                          // 0x21B  (0x5BC)
  pset  0x7                                                                        // 0x21C  (0xE47)
  call  label_232                                                                  // 0x21D  (0x461)
  pset  0x4                                                                        // 0x21E  (0xE44)
  call  label_142                                                                  // 0x21F  (0x465)
  ld    x,   0x3C                                                                  // 0x220  (0xB3C)
  ld    mx,  0xF                                                                   // 0x221  (0xE2F)

label_72:
  calz  copy_0x026_7_to_8_9                                                        // 0x222  (0x521)
  fan   a,   0x7                                                                   // 0x223  (0xD87)
  jp    nz,  label_72                                                              // 0x224  (0x722)
  pset  0x5                                                                        // 0x225  (0xE45)
  jp    label_159                                                                  // 0x226  (0x17)

springboard_copy_6_mx_my:
  pset  0x12                                                                       // 0x227  (0xE52)
  jp    copy_6_mx_my                                                               // 0x228  (0x22)

//
// Special return for copy_6_mx_my so it can safely return from the 1 bank to 0
//
copy_6_mx_my_bank0_ret:
  ret                                                                              // 0x229  (0xFDF)

reset_vect_cont:
  pset  0x1                                                                        // 0x22A  (0xE41)
  call  check_svd_voltage_set_xp_f                                                 // 0x22B  (0x4E3)
  // If voltage is low, jump
  jp    nz,  reset_vect_skip_voltage                                               // 0x22C  (0x72F)
  // X is 0xF70
  ld    x,   0x70                                                                  // 0x22D  (0xB70)
  // Set oscillation freq. 32kHz, and voltage >3.1 V
  ld    mx,  0x1                                                                   // 0x22E  (0xE21)

reset_vect_skip_voltage:
  ld    a,   0xF                                                                   // 0x22F  (0xE0F)
  ld    xp,  a                                                                     // 0x230  (0xE80)
  // X is 0xF40
  ld    x,   0x40                                                                  // 0x231  (0xB40)
  ld    a,   0x2                                                                   // 0x232  (0xE02)
  ld    yp,  a                                                                     // 0x233  (0xE90)
  // Y is 0x270
  ld    y,   0x70                                                                  // 0x234  (0x870)
  // Copy 0xF40 to 0x270. The K0 current input values
  ld    my,  mx                                                                    // 0x235  (0xECE)
  // Get only the first 3 bits
  and   my,  0x7                                                                   // 0x236  (0xCB7)
  call  springboard_set_init_mem_and_int                                           // 0x237  (0x442)
  calz  set_f_0x07D                                                                // 0x238  (0x509)
  // Y was not changed, so Y is 0x280
  ld    y,   0x80                                                                  // 0x239  (0x880)
  // 0x80 is copied into 0x036/7
  calz  if_0x7B_set_clear_0x32_store_yhl_set_0x059_to_0xF                          // 0x23A  (0x5BC)
  ld    a,   0x2                                                                   // 0x23B  (0xE02)
  ld    xp,  a                                                                     // 0x23C  (0xE80)
  // X is 0x270
  ld    x,   0x70                                                                  // 0x23D  (0xB70)
  cp    mx,  0x3                                                                   // 0x23E  (0xDE3)
  // If middle button was pressed, jump
  jp    z,   label_80                                                              // 0x23F  (0x656)
  pset  0x9                                                                        // 0x240  (0xE49)
  jp    label_294                                                                  // 0x241  (0x7F)

springboard_set_init_mem_and_int:
  pset  0x11                                                                       // 0x242  (0xE51)
  jp    set_init_mem_and_int                                                       // 0x243  (0xE0)

// 
// Continuation of set_init_mem_and_int
// Clears memory, including VRAM
//
set_init_mem_and_int_cont_mem_clear:
  ld    a,   0x0                                                                   // 0x244  (0xE00)
  ld    b,   0xE                                                                   // 0x245  (0xE1E)
  // Clear 14 * 8 = 112 nibbles from 0x000
  calz  clear_8_starting_at_a_xp                                                   // 0x246  (0x545)
  ld    a,   0x1                                                                   // 0x247  (0xE01)
  ld    b,   0x0                                                                   // 0x248  (0xE10)
  // Clear 128 nibbles from 0x100
  calz  clear_8_starting_at_a_xp                                                   // 0x249  (0x545)
  ld    a,   0x2                                                                   // 0x24A  (0xE02)
  ld    b,   0x7                                                                   // 0x24B  (0xE17)
  // Clear 7 * 8 = 56 nibbles from 0x200
  calz  clear_8_starting_at_a_xp                                                   // 0x24C  (0x545)
  ld    a,   0xE                                                                   // 0x24D  (0xE0E)
  ld    b,   0x5                                                                   // 0x24E  (0xE15)
  // Clear 5 * 8 = 40 nibbles from 0xE50
  calz  clear_8_starting_at_a_xp                                                   // 0x24F  (0x545)
  ld    b,   0x5                                                                   // 0x250  (0xE15)
  ld    x,   0x80                                                                  // 0x251  (0xB80)
  // Clear 40 nibbles from 0xE80
  calz  loop_clear_8                                                               // 0x252  (0x547)
  pset  0x12                                                                       // 0x253  (0xE52)
  jp    set_init_mem_and_int_cont_set_mem                                          // 0x254  (0x0)

set_init_mem_and_int_bank0_ret:
  ret                                                                              // 0x255  (0xFDF)

label_80:
  ld    x,   0x2C                                                                  // 0x256  (0xB2C)
  lbpx  mx,  0xFF                                                                  // 0x257  (0x9FF)
  ld    y,   0xFF                                                                  // 0x258  (0x8FF)
  ld    b,   0x2                                                                   // 0x259  (0xE12)
  call  label_81                                                                   // 0x25A  (0x46B)
  ld    x,   0x2C                                                                  // 0x25B  (0xB2C)
  lbpx  mx,  0x5A                                                                  // 0x25C  (0x95A)
  ld    y,   0xA5                                                                  // 0x25D  (0x8A5)
  ld    b,   0x1                                                                   // 0x25E  (0xE11)
  call  label_81                                                                   // 0x25F  (0x46B)
  ld    x,   0x2C                                                                  // 0x260  (0xB2C)
  lbpx  mx,  0xA5                                                                  // 0x261  (0x9A5)
  ld    y,   0x5A                                                                  // 0x262  (0x85A)
  ld    b,   0x4                                                                   // 0x263  (0xE14)
  call  label_81                                                                   // 0x264  (0x46B)
  ld    x,   0x2C                                                                  // 0x265  (0xB2C)
  lbpx  mx,  0x0                                                                   // 0x266  (0x900)
  ld    b,   0x2                                                                   // 0x267  (0xE12)
  call  label_85                                                                   // 0x268  (0x481)
  pset  0x9                                                                        // 0x269  (0xE49)
  jp    label_294                                                                  // 0x26A  (0x7F)

label_81:
  ld    m0,  b                                                                     // 0x26B  (0xF90)
  calz  one_a_xp                                                                   // 0x26C  (0x5F5)
  ld    x,   0x0                                                                   // 0x26D  (0xB00)
  ld    a,   yh                                                                    // 0x26E  (0xEB4)
  ld    b,   yl                                                                    // 0x26F  (0xEB9)

label_82:
  ldpx  mx,  a                                                                     // 0x270  (0xEE8)
  ldpx  mx,  a                                                                     // 0x271  (0xEE8)
  ldpx  mx,  b                                                                     // 0x272  (0xEE9)
  ldpx  mx,  b                                                                     // 0x273  (0xEE9)
  cp    xh,  0x0                                                                   // 0x274  (0xA40)
  jp    nz,  label_82                                                              // 0x275  (0x770)
  cp    xl,  0x0                                                                   // 0x276  (0xA50)
  jp    nz,  label_82                                                              // 0x277  (0x770)

label_83:
  pset  0x7                                                                        // 0x278  (0xE47)
  call  label_242                                                                  // 0x279  (0x4E1)
  calz  copy_video_buf_to_vram                                                     // 0x27A  (0x556)

label_84:
  calz  copy_0x026_7_to_8_9                                                        // 0x27B  (0x521)
  ld    b,   m0                                                                    // 0x27C  (0xFB0)
  cp    a,   b                                                                     // 0x27D  (0xF01)
  jp    nz,  label_84                                                              // 0x27E  (0x77B)
  calz  label_25                                                                   // 0x27F  (0x5BB)
  ret                                                                              // 0x280  (0xFDF)

label_85:
  ld    m0,  b                                                                     // 0x281  (0xF90)
  calz  one_a_xp                                                                   // 0x282  (0x5F5)
  ld    x,   0x0                                                                   // 0x283  (0xB00)

label_86:
  lbpx  mx,  0x1                                                                   // 0x284  (0x901)
  cp    xh,  0x8                                                                   // 0x285  (0xA48)
  jp    nz,  label_86                                                              // 0x286  (0x784)

label_87:
  lbpx  mx,  0x80                                                                  // 0x287  (0x980)
  cp    xh,  0x0                                                                   // 0x288  (0xA40)
  jp    nz,  label_87                                                              // 0x289  (0x787)
  ld    x,   0x0                                                                   // 0x28A  (0xB00)
  lbpx  mx,  0xFF                                                                  // 0x28B  (0x9FF)
  ld    x,   0x3E                                                                  // 0x28C  (0xB3E)
  lbpx  mx,  0xFF                                                                  // 0x28D  (0x9FF)
  ld    x,   0x80                                                                  // 0x28E  (0xB80)
  lbpx  mx,  0xFF                                                                  // 0x28F  (0x9FF)
  ld    x,   0xBE                                                                  // 0x290  (0xBBE)
  lbpx  mx,  0xFF                                                                  // 0x291  (0x9FF)
  jp    label_83                                                                   // 0x292  (0x78)

label_88:
  ld    a,   0x0                                                                   // 0x293  (0xE00)
  calz  label_39                                                                   // 0x294  (0x5ED)
  calz  clear_page_0x100                                                           // 0x295  (0x540)
  calz  copy_0x026_7_to_8_9                                                        // 0x296  (0x521)

label_89:
  calz  label_30                                                                   // 0x297  (0x5CE)
  lbpx  mx,  0xC4                                                                  // 0x298  (0x9C4)
  pset  0x5                                                                        // 0x299  (0xE45)
  call  label_181                                                                  // 0x29A  (0x4A6)
  ld    b,   0x5                                                                   // 0x29B  (0xE15)
  ld    m5,  b                                                                     // 0x29C  (0xF95)
  ld    a,   m4                                                                    // 0x29D  (0xFA4)
  cp    a,   0x6                                                                   // 0x29E  (0xDC6)
  jp    c,   label_90                                                              // 0x29F  (0x2A1)
  add   a,   0x3                                                                   // 0x2A0  (0xC03)

label_90:
  ld    m4,  a                                                                     // 0x2A1  (0xF84)
  calz  one_a_xp                                                                   // 0x2A2  (0x5F5)
  ld    x,   0xE2                                                                  // 0x2A3  (0xBE2)

label_91:
  dec   m4                                                                         // 0x2A4  (0xF74)
  ld    a,   m4                                                                    // 0x2A5  (0xFA4)
  rlc   a                                                                          // 0x2A6  (0xAF0)
  ld    a,   0x5                                                                   // 0x2A7  (0xE05)
  rlc   a                                                                          // 0x2A8  (0xAF0)
  pset  0x5                                                                        // 0x2A9  (0xE45)
  call  render_clock_with_b_0                                                      // 0x2AA  (0x4EF)
  dec   m5                                                                         // 0x2AB  (0xF75)
  jp    nz,  label_91                                                              // 0x2AC  (0x7A4)
  calz  copy_video_buf_to_vram                                                     // 0x2AD  (0x556)
  pset  0xF                                                                        // 0x2AE  (0xE4F)
  call  label_357                                                                  // 0x2AF  (0x400)
  jp    nz,  label_93                                                              // 0x2B0  (0x7C0)

label_92:
  calz  store_0x02_into_0x022_3                                                    // 0x2B1  (0x51F)
  fan   b,   0x2                                                                   // 0x2B2  (0xD92)
  pset  0x5                                                                        // 0x2B3  (0xE45)
  jp    nz,  label_157                                                             // 0x2B4  (0x708)
  cp    a,   0x5                                                                   // 0x2B5  (0xDC5)
  pset  0x5                                                                        // 0x2B6  (0xE45)
  jp    z,   label_167                                                             // 0x2B7  (0x653)
  ld    x,   0x7C                                                                  // 0x2B8  (0xB7C)
  cp    mx,  0x0                                                                   // 0x2B9  (0xDE0)
  pset  0x5                                                                        // 0x2BA  (0xE45)
  jp    z,   label_157                                                             // 0x2BB  (0x608)
  ld    x,   0x2E                                                                  // 0x2BC  (0xB2E)
  cp    mx,  0x0                                                                   // 0x2BD  (0xDE0)
  jp    z,   label_92                                                              // 0x2BE  (0x6B1)
  jp    label_89                                                                   // 0x2BF  (0x97)

label_93:
  pset  0x3                                                                        // 0x2C0  (0xE43)
  call  label_101                                                                  // 0x2C1  (0x407)
  jp    label_88                                                                   // 0x2C2  (0x93)

label_94:
  calz  copy_0x026_7_to_8_9                                                        // 0x2C3  (0x521)
  or    a,   b                                                                     // 0x2C4  (0xAD1)
  fan   a,   0x7                                                                   // 0x2C5  (0xD87)
  jp    z,   label_95                                                              // 0x2C6  (0x6CD)
  ld    x,   0x77                                                                  // 0x2C7  (0xB77)
  ld    a,   mx                                                                    // 0x2C8  (0xEC2)
  cp    a,   0x0                                                                   // 0x2C9  (0xDC0)
  jp    z,   label_95                                                              // 0x2CA  (0x6CD)
  ld    x,   0x57                                                                  // 0x2CB  (0xB57)
  ld    mx,  a                                                                     // 0x2CC  (0xEC8)

label_95:
  ld    x,   0x29                                                                  // 0x2CD  (0xB29)
  fan   mx,  0x4                                                                   // 0x2CE  (0xDA4)
  jp    z,   label_96                                                              // 0x2CF  (0x6D9)
  calz  label_25                                                                   // 0x2D0  (0x5BB)
  ld    x,   0x76                                                                  // 0x2D1  (0xB76)
  ld    a,   mx                                                                    // 0x2D2  (0xEC2)
  ld    x,   0x75                                                                  // 0x2D3  (0xB75)
  add   mx,  0x1                                                                   // 0x2D4  (0xC21)
  cp    mx,  a                                                                     // 0x2D5  (0xF08)
  jp    c,   label_99                                                              // 0x2D6  (0x2EE)
  ld    mx,  0x0                                                                   // 0x2D7  (0xE20)
  jp    label_99                                                                   // 0x2D8  (0xEE)

label_96:
  fan   mx,  0x2                                                                   // 0x2D9  (0xDA2)
  jp    z,   label_97                                                              // 0x2DA  (0x6DF)
  calz  label_25                                                                   // 0x2DB  (0x5BB)
  rst   f,   0xE                                                                   // 0x2DC  (0xF5E)
  set   f,   0x2                                                                   // 0x2DD  (0xF42)
  jp    label_100                                                                  // 0x2DE  (0xF0)

label_97:
  fan   mx,  0x1                                                                   // 0x2DF  (0xDA1)
  jp    z,   label_98                                                              // 0x2E0  (0x6E5)
  calz  label_25                                                                   // 0x2E1  (0x5BB)
  set   f,   0x1                                                                   // 0x2E2  (0xF41)
  set   f,   0x2                                                                   // 0x2E3  (0xF42)
  jp    label_100                                                                  // 0x2E4  (0xF0)

label_98:
  ld    x,   0x57                                                                  // 0x2E5  (0xB57)
  cp    mx,  0x0                                                                   // 0x2E6  (0xDE0)
  jp    nz,  label_99                                                              // 0x2E7  (0x7EE)
  ld    x,   0x77                                                                  // 0x2E8  (0xB77)
  cp    mx,  0x0                                                                   // 0x2E9  (0xDE0)
  jp    z,   label_99                                                              // 0x2EA  (0x6EE)
  set   f,   0x1                                                                   // 0x2EB  (0xF41)
  rst   f,   0xD                                                                   // 0x2EC  (0xF5D)
  jp    label_100                                                                  // 0x2ED  (0xF0)

label_99:
  rst   f,   0xE                                                                   // 0x2EE  (0xF5E)
  rst   f,   0xD                                                                   // 0x2EF  (0xF5D)

label_100:
  ld    x,   0x75                                                                  // 0x2F0  (0xB75)
  ld    a,   mx                                                                    // 0x2F1  (0xEC2)
  ret                                                                              // 0x2F2  (0xFDF)
  nop7                                                                             // 0x2F3  (0xFFF)
  nop7                                                                             // 0x2F4  (0xFFF)
  nop7                                                                             // 0x2F5  (0xFFF)
  nop7                                                                             // 0x2F6  (0xFFF)
  nop7                                                                             // 0x2F7  (0xFFF)
  nop7                                                                             // 0x2F8  (0xFFF)
  nop7                                                                             // 0x2F9  (0xFFF)
  nop7                                                                             // 0x2FA  (0xFFF)
  nop7                                                                             // 0x2FB  (0xFFF)
  nop7                                                                             // 0x2FC  (0xFFF)
  nop7                                                                             // 0x2FD  (0xFFF)
  nop7                                                                             // 0x2FE  (0xFFF)
  nop7                                                                             // 0x2FF  (0xFFF)
// Jump table for label_101
  ret                                                                              // 0x300  (0xFDF)  
  jp    label_102                                                                  // 0x301  (0xC)
  jp    label_106                                                                  // 0x302  (0x1C)
  jp    label_107                                                                  // 0x303  (0x24)
  jp    label_109                                                                  // 0x304  (0x29)
  jp    label_112                                                                  // 0x305  (0x4B)
  jp    label_116                                                                  // 0x306  (0x74)

label_101:
  calz  zero_b_xp                                                                  // 0x307  (0x5F2)
  ld    x,   0x5C                                                                  // 0x308  (0xB5C)
  ld    a,   mx                                                                    // 0x309  (0xEC2)
  ld    mx,  0x0                                                                   // 0x30A  (0xE20)
  jpba                                                                             // 0x30B  (0xFE8)

label_102:
  ld    x,   0x4A                                                                  // 0x30C  (0xB4A)
  ld    mx,  0xF                                                                   // 0x30D  (0xE2F)
  ld    x,   0x5D                                                                  // 0x30E  (0xB5D)
  ld    b,   mx                                                                    // 0x30F  (0xEC6)
  ld    a,   0x2                                                                   // 0x310  (0xE02)
  ld    xp,  a                                                                     // 0x311  (0xE80)
  ld    x,   0x4                                                                   // 0x312  (0xB04)
  cp    b,   0x1                                                                   // 0x313  (0xDD1)
  jp    z,   label_104                                                             // 0x314  (0x617)
  lbpx  mx,  0x0                                                                   // 0x315  (0x900)

label_103:
  jp    label_105                                                                  // 0x316  (0x18)

label_104:
  lbpx  mx,  0x3D                                                                  // 0x317  (0x93D)

label_105:
  ld    a,   0x8                                                                   // 0x318  (0xE08)
  ld    y,   0xA5                                                                  // 0x319  (0x8A5)
  calz  label_24                                                                   // 0x31A  (0x5B7)
  ret                                                                              // 0x31B  (0xFDF)

label_106:
  ld    x,   0x5D                                                                  // 0x31C  (0xB5D)
  ld    a,   0x2                                                                   // 0x31D  (0xE02)
  ld    yp,  a                                                                     // 0x31E  (0xE90)
  ld    y,   0x8                                                                   // 0x31F  (0x808)
  cp    mx,  0x1                                                                   // 0x320  (0xDE1)
  jp    nz,  label_108                                                             // 0x321  (0x727)
  ld    my,  0xD                                                                   // 0x322  (0xE3D)
  jp    label_105                                                                  // 0x323  (0x18)

label_107:
  ld    a,   0x2                                                                   // 0x324  (0xE02)
  ld    yp,  a                                                                     // 0x325  (0xE90)
  ld    y,   0x9                                                                   // 0x326  (0x809)

label_108:
  ld    my,  0x1                                                                   // 0x327  (0xE31)
  jp    label_103                                                                  // 0x328  (0x16)

label_109:
  ld    x,   0x4B                                                                  // 0x329  (0xB4B)
  push  mx                                                                         // 0x32A  (0xFC2)
  ld    mx,  0xF                                                                   // 0x32B  (0xE2F)
  ld    a,   0x4                                                                   // 0x32C  (0xE04)
  ld    b,   0x8                                                                   // 0x32D  (0xE18)
  ld    y,   0x2                                                                   // 0x32E  (0x802)
  call  label_124                                                                  // 0x32F  (0x4D5)
  ld    a,   0x0                                                                   // 0x330  (0xE00)
  ld    yp,  a                                                                     // 0x331  (0xE90)
  ld    y,   0x4B                                                                  // 0x332  (0x84B)
  pop   my                                                                         // 0x333  (0xFD3)
  ld    a,   0x2                                                                   // 0x334  (0xE02)
  ld    xp,  a                                                                     // 0x335  (0xE80)
  ld    x,   0x6                                                                   // 0x336  (0xB06)
  lbpx  mx,  0xB4                                                                  // 0x337  (0x9B4)
  ld    y,   0x5D                                                                  // 0x338  (0x85D)
  cp    my,  0x1                                                                   // 0x339  (0xDF1)
  jp    nz,  label_110                                                             // 0x33A  (0x73D)
  ld    x,   0x6                                                                   // 0x33B  (0xB06)
  lbpx  mx,  0x19                                                                  // 0x33C  (0x919)

label_110:
  ld    y,   0x4D                                                                  // 0x33D  (0x84D)
  add   my,  0x1                                                                   // 0x33E  (0xC31)
  cp    my,  0x8                                                                   // 0x33F  (0xDF8)
  jp    c,   label_111                                                             // 0x340  (0x24A)
  ld    my,  0x8                                                                   // 0x341  (0xE38)
  ld    y,   0x48                                                                  // 0x342  (0x848)
  fan   my,  0x8                                                                   // 0x343  (0xDB8)
  jp    nz,  label_111                                                             // 0x344  (0x74A)
  ld    x,   0xD                                                                   // 0x345  (0xB0D)
  calz  clear_0x07D                                                                // 0x346  (0x512)
  lbpx  mx,  0x0                                                                   // 0x347  (0x900)
  ld    mx,  0x0                                                                   // 0x348  (0xE20)
  calz  set_f_0x07D                                                                // 0x349  (0x509)

label_111:
  ret                                                                              // 0x34A  (0xFDF)

label_112:
  ld    a,   0x3                                                                   // 0x34B  (0xE03)
  ld    y,   0xAE                                                                  // 0x34C  (0x8AE)
  calz  label_24                                                                   // 0x34D  (0x5B7)
  call  jp_copy_video_buf_8x                                                       // 0x34E  (0x4FC)
  ld    b,   0x3                                                                   // 0x34F  (0xE13)
  pset  0x8                                                                        // 0x350  (0xE48)
  call  label_271                                                                  // 0x351  (0x49E)
  call  jp_copy_video_buf_8x                                                       // 0x352  (0x4FC)
  calz  zero_a_xp                                                                  // 0x353  (0x5EF)
  ld    x,   0x50                                                                  // 0x354  (0xB50)
  ld    a,   mx                                                                    // 0x355  (0xEC2)
  pset  0xD                                                                        // 0x356  (0xE4D)
  call  label_346                                                                  // 0x357  (0x4C6)
  ld    x,   0x51                                                                  // 0x358  (0xB51)
  ld    b,   mx                                                                    // 0x359  (0xEC6)
  ld    x,   0x42                                                                  // 0x35A  (0xB42)
  ld    a,   mx                                                                    // 0x35B  (0xEC2)
  ld    x,   0x90                                                                  // 0x35C  (0xB90)

label_113:
  cp    a,   mx                                                                    // 0x35D  (0xF02)
  ldpx  a,   a                                                                     // 0x35E  (0xEE0)
  jp    c,   label_114                                                             // 0x35F  (0x262)
  cp    b,   mx                                                                    // 0x360  (0xF06)
  jp    nc,  label_115                                                             // 0x361  (0x366)

label_114:
  ldpx  a,   a                                                                     // 0x362  (0xEE0)
  ldpx  a,   a                                                                     // 0x363  (0xEE0)
  ldpx  a,   a                                                                     // 0x364  (0xEE0)
  jp    label_113                                                                  // 0x365  (0x5D)

label_115:
  ldpx  a,   a                                                                     // 0x366  (0xEE0)
  ldpx  a,   mx                                                                    // 0x367  (0xEE2)
  ld    b,   mx                                                                    // 0x368  (0xEC6)
  ld    x,   0x50                                                                  // 0x369  (0xB50)
  ld    mx,  a                                                                     // 0x36A  (0xEC8)
  ld    x,   0x5D                                                                  // 0x36B  (0xB5D)
  ld    mx,  b                                                                     // 0x36C  (0xEC9)
  pset  0x4                                                                        // 0x36D  (0xE44)
  call  label_142                                                                  // 0x36E  (0x465)
  ld    b,   0x4                                                                   // 0x36F  (0xE14)
  pset  0x8                                                                        // 0x370  (0xE48)
  call  label_271                                                                  // 0x371  (0x49E)
  pset  0xD                                                                        // 0x372  (0xE4D)
  jp    label_347                                                                  // 0x373  (0xD2)

label_116:
  calz  label_38                                                                   // 0x374  (0x5EC)
  call  jp_copy_video_buf_8x                                                       // 0x375  (0x4FC)
  calz  zero_a_xp                                                                  // 0x376  (0x5EF)
  ld    x,   0x74                                                                  // 0x377  (0xB74)
  ldpx  mx,  0x0                                                                   // 0x378  (0xE60)
  ld    x,   0x48                                                                  // 0x379  (0xB48)
  lbpx  mx,  0x0                                                                   // 0x37A  (0x900)
  lbpx  mx,  0xF0                                                                  // 0x37B  (0x9F0)
  lbpx  mx,  0x0                                                                   // 0x37C  (0x900)
  ld    x,   0x5D                                                                  // 0x37D  (0xB5D)
  ld    a,   mx                                                                    // 0x37E  (0xEC2)
  ld    m6,  a                                                                     // 0x37F  (0xF86)
  ld    y,   0xBF                                                                  // 0x380  (0x8BF)
  calz  if_0x7B_set_clear_0x32_store_yhl_set_0x059_to_0xF                          // 0x381  (0x5BC)
  call  label_123                                                                  // 0x382  (0x4D2)
  call  label_123                                                                  // 0x383  (0x4D2)
  call  label_123                                                                  // 0x384  (0x4D2)
  call  label_123                                                                  // 0x385  (0x4D2)
  ld    y,   0xC4                                                                  // 0x386  (0x8C4)
  calz  if_0x7B_set_clear_0x32_store_yhl_set_0x059_to_0xF                          // 0x387  (0x5BC)
  call  label_123                                                                  // 0x388  (0x4D2)
  ld    y,   0xC9                                                                  // 0x389  (0x8C9)
  calz  if_0x7B_set_clear_0x32_store_yhl_set_0x059_to_0xF                          // 0x38A  (0x5BC)
  call  label_123                                                                  // 0x38B  (0x4D2)
  calz  zero_a_xp                                                                  // 0x38C  (0x5EF)
  ld    x,   0x5D                                                                  // 0x38D  (0xB5D)
  ld    mx,  0x0                                                                   // 0x38E  (0xE20)
  ld    x,   0x4E                                                                  // 0x38F  (0xB4E)
  cp    mx,  0x0                                                                   // 0x390  (0xDE0)
  jp    z,   label_118                                                             // 0x391  (0x69E)
  call  label_125                                                                  // 0x392  (0x4D7)
  ld    x,   0x1B                                                                  // 0x393  (0xB1B)
  calz  copy_xhl_to_0x022_or_loop_0x023                                            // 0x394  (0x53C)
  ld    x,   0x48                                                                  // 0x395  (0xB48)
  calz  copy_xhl_to_0x022                                                          // 0x396  (0x52C)

label_117:
  call  label_125                                                                  // 0x397  (0x4D7)
  calz  clear_page_0x100                                                           // 0x398  (0x540)
  call  label_126                                                                  // 0x399  (0x4E4)
  calz  or_0x022_and_0x023                                                         // 0x39A  (0x535)
  jp    nz,  label_117                                                             // 0x39B  (0x797)
  ld    x,   0x1B                                                                  // 0x39C  (0xB1B)
  calz  copy_xhl_to_0x022_or_loop_0x023                                            // 0x39D  (0x53C)

label_118:
  ld    y,   0xCE                                                                  // 0x39E  (0x8CE)
  calz  if_0x7B_set_clear_0x32_store_yhl_set_0x059_to_0xF                          // 0x39F  (0x5BC)
  calz  copy_0x026_7_to_8_9                                                        // 0x3A0  (0x521)

label_119:
  calz  clear_page_0x100                                                           // 0x3A1  (0x540)
  calz  zero_b_xp                                                                  // 0x3A2  (0x5F2)
  ld    x,   0x80                                                                  // 0x3A3  (0xB80)
  add   mx,  0x8                                                                   // 0x3A4  (0xC28)
  ld    b,   mx                                                                    // 0x3A5  (0xEC6)
  ld    x,   0x3A                                                                  // 0x3A6  (0xB3A)
  lbpx  mx,  0x0                                                                   // 0x3A7  (0x900)
  ld    a,   0x3                                                                   // 0x3A8  (0xE03)
  call  label_128                                                                  // 0x3A9  (0x4EE)
  calz  zero_b_xp                                                                  // 0x3AA  (0x5F2)
  ld    x,   0x3A                                                                  // 0x3AB  (0xB3A)
  lbpx  mx,  0x20                                                                  // 0x3AC  (0x920)
  ld    a,   0x4                                                                   // 0x3AD  (0xE04)
  call  label_127                                                                  // 0x3AE  (0x4ED)
  pset  0x2                                                                        // 0x3AF  (0xE42)
  call  label_70                                                                   // 0x3B0  (0x400)
  jp    z,   label_119                                                             // 0x3B1  (0x6A1)
  calz  label_25                                                                   // 0x3B2  (0x5BB)
  calz  one_a_xp                                                                   // 0x3B3  (0x5F5)
  ld    x,   0xD0                                                                  // 0x3B4  (0xBD0)
  ld    b,   0x1                                                                   // 0x3B5  (0xE11)
  ld    a,   0x9                                                                   // 0x3B6  (0xE09)
  call  label_122                                                                  // 0x3B7  (0x4D0)
  ld    b,   0x0                                                                   // 0x3B8  (0xE10)
  ld    yp,  b                                                                     // 0x3B9  (0xE91)
  ld    y,   0x54                                                                  // 0x3BA  (0x854)
  ldpy  a,   my                                                                    // 0x3BB  (0xEF3)
  ld    x,   0x50                                                                  // 0x3BC  (0xB50)
  call  label_122                                                                  // 0x3BD  (0x4D0)
  ld    b,   0x0                                                                   // 0x3BE  (0xE10)
  ld    a,   my                                                                    // 0x3BF  (0xEC3)
  cp    a,   0x0                                                                   // 0x3C0  (0xDC0)
  jp    z,   label_120                                                             // 0x3C1  (0x6C4)
  ld    x,   0x40                                                                  // 0x3C2  (0xB40)
  call  label_122                                                                  // 0x3C3  (0x4D0)

label_120:
  ld    a,   0x2                                                                   // 0x3C4  (0xE02)
  ld    b,   0x2                                                                   // 0x3C5  (0xE12)
  pset  0xA                                                                        // 0x3C6  (0xE4A)
  call  label_305                                                                  // 0x3C7  (0x4F0)

label_121:
  pset  0x2                                                                        // 0x3C8  (0xE42)
  call  label_70                                                                   // 0x3C9  (0x400)
  jp    z,   label_121                                                             // 0x3CA  (0x6C8)
  calz  label_25                                                                   // 0x3CB  (0x5BB)
  ld    b,   0xE                                                                   // 0x3CC  (0xE1E)
  pset  0x5                                                                        // 0x3CD  (0xE45)
  call  label_156                                                                  // 0x3CE  (0x400)
  jp    label_119                                                                  // 0x3CF  (0xA1)

label_122:
  pset  0x7                                                                        // 0x3D0  (0xE47)
  jp    misc_render                                                                // 0x3D1  (0xA5)

label_123:
  ld    a,   0xA                                                                   // 0x3D2  (0xE0A)
  ld    b,   0xA                                                                   // 0x3D3  (0xE1A)
  ld    y,   0x5                                                                   // 0x3D4  (0x805)

label_124:
  pset  0x8                                                                        // 0x3D5  (0xE48)
  jp    label_273                                                                  // 0x3D6  (0xA9)

label_125:
  calz  clear_page_0x100                                                           // 0x3D7  (0x540)
  calz  zero_a_xp                                                                  // 0x3D8  (0x5EF)
  ld    b,   m6                                                                    // 0x3D9  (0xFB6)
  ld    x,   0x5D                                                                  // 0x3DA  (0xB5D)
  ld    mx,  b                                                                     // 0x3DB  (0xEC9)
  ld    a,   0x4                                                                   // 0x3DC  (0xE04)
  ld    x,   0x0                                                                   // 0x3DD  (0xB00)
  pset  0xA                                                                        // 0x3DE  (0xE4A)
  call  jp_table_0xA00                                                             // 0x3DF  (0x4BD)
  ld    a,   m1                                                                    // 0x3E0  (0xFA1)
  ld    x,   0x3A                                                                  // 0x3E1  (0xB3A)
  lbpx  mx,  0x0                                                                   // 0x3E2  (0x900)
  call  label_127                                                                  // 0x3E3  (0x4ED)

label_126:
  calz  zero_b_xp                                                                  // 0x3E4  (0x5F2)
  ld    x,   0x5D                                                                  // 0x3E5  (0xB5D)
  ld    mx,  0x0                                                                   // 0x3E6  (0xE20)
  ld    a,   0x0                                                                   // 0x3E7  (0xE00)
  ld    x,   0x3A                                                                  // 0x3E8  (0xB3A)
  lbpx  mx,  0x20                                                                  // 0x3E9  (0x920)
  call  label_127                                                                  // 0x3EA  (0x4ED)
  calz  copy_video_buf_to_vram                                                     // 0x3EB  (0x556)
  ret                                                                              // 0x3EC  (0xFDF)

label_127:
  ld    b,   0x0                                                                   // 0x3ED  (0xE10)

label_128:
  push  b                                                                          // 0x3EE  (0xFC1)
  calz  zero_b_xp                                                                  // 0x3EF  (0x5F2)
  pop   b                                                                          // 0x3F0  (0xFD1)
  push  b                                                                          // 0x3F1  (0xFC1)
  push  a                                                                          // 0x3F2  (0xFC0)
  pset  0x9                                                                        // 0x3F3  (0xE49)
  call  label_288                                                                  // 0x3F4  (0x428)
  pop   a                                                                          // 0x3F5  (0xFD0)
  calz  zero_b_xp                                                                  // 0x3F6  (0x5F2)
  pop   b                                                                          // 0x3F7  (0xFD1)
  ld    x,   0x3B                                                                  // 0x3F8  (0xB3B)
  add   mx,  0x8                                                                   // 0x3F9  (0xC28)
  pset  0x9                                                                        // 0x3FA  (0xE49)
  jp    label_289                                                                  // 0x3FB  (0x39)

//
// Jumps to label_284
//
jp_copy_video_buf_8x:
  pset  0x9                                                                        // 0x3FC  (0xE49)
  jp    copy_video_buf_8x                                                          // 0x3FD  (0x6)
  nop7                                                                             // 0x3FE  (0xFFF)
  nop7                                                                             // 0x3FF  (0xFFF)

//
// Copy in-mem video buffer to VRAM
// TODO: These comments and labels are incomplete
//
copy_buf_and_render_misc:
  calz  zero_a_xp                                                                  // 0x400  (0x5EF)
  // 0x04B
  ld    x,   0x4B                                                                  // 0x401  (0xB4B)
  cp    mx,  0x0                                                                   // 0x402  (0xDE0)
  // If 0x04B != 0, jump
  jp    nz,  jp_copy_buf_misc                                                      // 0x403  (0x71B)
  calz  one_a_xp                                                                   // 0x404  (0x5F5)
  ld    yp,  a                                                                     // 0x405  (0xE90)
  // Set X to 0x100
  ld    x,   0x0                                                                   // 0x406  (0xB00)
  // Set Y to 0x180
  ld    y,   0x80                                                                  // 0x407  (0x880)

loop_131:
  // Set 0x100-0x13F to 0xF
  // Set 0x180-0x1BF to 0xF
  ldpx  mx,  0xF                                                                   // 0x408  (0xE6F)
  ldpy  my,  0xF                                                                   // 0x409  (0xE7F)
  cp    xh,  0x4                                                                   // 0x40A  (0xA44)
  // If XH < 4, loop
  jp    c,   loop_131                                                              // 0x40B  (0x208)
  calz  check_0x04A_highbit                                                        // 0x40C  (0x5B3)
  // If 0x04A high bit is clear, return
  jp    z,   loop_131_ret                                                          // 0x40D  (0x61A)
  // 0x04A high bit is set
  // Add one to 0x04A
  add   mx,  0x1                                                                   // 0x40E  (0xC21)
  // Set 0x04A high bit
  or    mx,  0x8                                                                   // 0x40F  (0xCE8)
  ld    a,   mx                                                                    // 0x410  (0xEC2)
  rrc   a                                                                          // 0x411  (0xE8C)
  and   a,   0x1                                                                   // 0x412  (0xC81)
  add   a,   0x0                                                                   // 0x413  (0xC00)
  ld    b,   0x1                                                                   // 0x414  (0xE11)
  ld    xp,  b                                                                     // 0x415  (0xE81)
  ld    b,   0x2                                                                   // 0x416  (0xE12)
  ld    x,   0x20                                                                  // 0x417  (0xB20)
  pset  0x7                                                                        // 0x418  (0xE47)
  call  misc_render                                                                // 0x419  (0x4A5)

loop_131_ret:
  ret                                                                              // 0x41A  (0xFDF)

jp_copy_buf_misc:
  calz  check_0x04A_highbit                                                        // 0x41B  (0x5B3)
  // If 0x04A high bit is clear, jump
  jp    z,   jp_copy_buf_misc_2                                                    // 0x41C  (0x62A)
  add   mx,  0x1                                                                   // 0x41D  (0xC21)
  or    mx,  0x8                                                                   // 0x41E  (0xCE8)
  ld    a,   mx                                                                    // 0x41F  (0xEC2)
  rrc   a                                                                          // 0x420  (0xE8C)
  and   a,   0x1                                                                   // 0x421  (0xC81)
  add   a,   0xA                                                                   // 0x422  (0xC0A)
  ld    b,   0x1                                                                   // 0x423  (0xE11)
  ld    xp,  b                                                                     // 0x424  (0xE81)
  ld    b,   0x3                                                                   // 0x425  (0xE13)
  ld    x,   0x30                                                                  // 0x426  (0xB30)
  pset  0x7                                                                        // 0x427  (0xE47)
  call  misc_render                                                                // 0x428  (0x4A5)
  jp    jp_copy_buf_misc_3                                                         // 0x429  (0x32)

jp_copy_buf_misc_2:
  calz  zero_a_xp_and_bit_high_at_0x048                                            // 0x42A  (0x5FB)
  // If 0x048 high bit is clear, jump
  jp    z,   jp_copy_buf_misc_3                                                    // 0x42B  (0x632)
  calz  one_a_xp                                                                   // 0x42C  (0x5F5)
  ld    x,   0x30                                                                  // 0x42D  (0xB30)
  ld    b,   0x2                                                                   // 0x42E  (0xE12)
  ld    a,   0x2                                                                   // 0x42F  (0xE02)
  pset  0x7                                                                        // 0x430  (0xE47)
  call  misc_render                                                                // 0x431  (0x4A5)

jp_copy_buf_misc_3:
  calz  zero_a_xp                                                                  // 0x432  (0x5EF)
  ld    x,   0x7E                                                                  // 0x433  (0xB7E)
  add   mx,  0x1                                                                   // 0x434  (0xC21)
  ld    a,   mx                                                                    // 0x435  (0xEC2)
  rrc   a                                                                          // 0x436  (0xE8C)
  and   a,   0x1                                                                   // 0x437  (0xC81)
  add   a,   0xE                                                                   // 0x438  (0xC0E)
  ld    m4,  a                                                                     // 0x439  (0xF84)
  ld    x,   0x4D                                                                  // 0x43A  (0xB4D)
  ld    a,   mx                                                                    // 0x43B  (0xEC2)
  cp    a,   0x8                                                                   // 0x43C  (0xDC8)
  // If a >= 8, set it to 8
  jp    c,   skip_set_a_8_135                                                      // 0x43D  (0x23F)
  ld    a,   0x8                                                                   // 0x43E  (0xE08)

skip_set_a_8_135:
  ld    m3,  a                                                                     // 0x43F  (0xF83)
  add   a,   0xD                                                                   // 0x440  (0xC0D)
  jp    nc,  jp_copy_buf_misc_4                                                    // 0x441  (0x356)
  rrc   a                                                                          // 0x442  (0xE8C)
  and   a,   0x3                                                                   // 0x443  (0xC83)
  add   a,   0x1                                                                   // 0x444  (0xC01)
  ld    y,   0x0                                                                   // 0x445  (0x800)
  ld    yh,  a                                                                     // 0x446  (0xE94)
  calz  one_a_xp                                                                   // 0x447  (0x5F5)
  ld    yp,  a                                                                     // 0x448  (0xE90)
  ld    x,   0x0                                                                   // 0x449  (0xB00)

loop_137:
  ldpx  mx,  my                                                                    // 0x44A  (0xEEB)
  ldpy  a,   a                                                                     // 0x44B  (0xEF0)
  cp    xh,  0x4                                                                   // 0x44C  (0xA44)
  jp    c,   loop_137                                                              // 0x44D  (0x24A)
  rst   f,   0xE                                                                   // 0x44E  (0xF5E)
  adc   xh,  0x4                                                                   // 0x44F  (0xA04)
  rst   f,   0xE                                                                   // 0x450  (0xF5E)
  adc   yh,  0x4                                                                   // 0x451  (0xA24)

loop_138:
  ldpx  mx,  my                                                                    // 0x452  (0xEEB)
  ldpy  a,   a                                                                     // 0x453  (0xEF0)
  cp    xh,  0xC                                                                   // 0x454  (0xA4C)
  jp    c,   loop_138                                                              // 0x455  (0x252)

jp_copy_buf_misc_4:
  calz  one_a_xp                                                                   // 0x456  (0x5F5)
  ld    x,   0xB0                                                                  // 0x457  (0xBB0)
  inc   m3                                                                         // 0x458  (0xF63)

loop_140:
  dec   m3                                                                         // 0x459  (0xF73)
  // If m3 == 0, return
  jp    z,   ret_140                                                               // 0x45A  (0x664)
  ld    b,   0x1                                                                   // 0x45B  (0xE11)
  ld    a,   m4                                                                    // 0x45C  (0xFA4)
  pset  0x7                                                                        // 0x45D  (0xE47)
  call  misc_render                                                                // 0x45E  (0x4A5)
  rst   f,   0xE                                                                   // 0x45F  (0xF5E)
  adc   xh,  0x7                                                                   // 0x460  (0xA07)
  jp    c,   loop_140                                                              // 0x461  (0x259)
  adc   xh,  0xF                                                                   // 0x462  (0xA0F)
  jp    loop_140                                                                   // 0x463  (0x59)

ret_140:
  ret                                                                              // 0x464  (0xFDF)

label_142:
  calz  zero_a_xp                                                                  // 0x465  (0x5EF)
  ld    x,   0x5F                                                                  // 0x466  (0xB5F)
  ldpx  mx,  0x0                                                                   // 0x467  (0xE60)
  ld    x,   0x66                                                                  // 0x468  (0xB66)
  lbpx  mx,  0x0                                                                   // 0x469  (0x900)
  ld    x,   0x5D                                                                  // 0x46A  (0xB5D)
  ldpx  b,   mx                                                                    // 0x46B  (0xEE6)
  ld    a,   mx                                                                    // 0x46C  (0xEC2)
  ld    x,   0x6E                                                                  // 0x46D  (0xB6E)
  pset  0xA                                                                        // 0x46E  (0xE4A)
  call  jp_table_0xA00                                                             // 0x46F  (0x4BD)
  ld    x,   0x5D                                                                  // 0x470  (0xB5D)
  ldpx  b,   mx                                                                    // 0x471  (0xEE6)
  ld    a,   mx                                                                    // 0x472  (0xEC2)
  ld    x,   0x0                                                                   // 0x473  (0xB00)
  call  jp_table_0xB00                                                             // 0x474  (0x484)
  ld    b,   0x0                                                                   // 0x475  (0xE10)
  ld    a,   m1                                                                    // 0x476  (0xFA1)
  add   a,   0xB                                                                   // 0x477  (0xC0B)
  adc   b,   0x8                                                                   // 0x478  (0xC58)
  ld    x,   0x6A                                                                  // 0x479  (0xB6A)
  call  jp_table_0x980                                                             // 0x47A  (0x482)
  ld    b,   0x0                                                                   // 0x47B  (0xE10)
  ld    a,   m0                                                                    // 0x47C  (0xFA0)
  add   a,   0x0                                                                   // 0x47D  (0xC00)
  adc   b,   0xC                                                                   // 0x47E  (0xC5C)
  ld    x,   0x64                                                                  // 0x47F  (0xB64)
  pset  0xB                                                                        // 0x480  (0xE4B)
  jpba                                                                             // 0x481  (0xFE8)

jp_table_0x980:
  pset  0x9                                                                        // 0x482  (0xE49)
  jpba                                                                             // 0x483  (0xFE8)

jp_table_0xB00:
  pset  0xB                                                                        // 0x484  (0xE4B)
  jpba                                                                             // 0x485  (0xFE8)

label_145:
  calz  zero_a_xp                                                                  // 0x486  (0x5EF)
  ld    x,   0x5F                                                                  // 0x487  (0xB5F)
  add   mx,  0xF                                                                   // 0x488  (0xC2F)
  jp    c,   label_146                                                             // 0x489  (0x296)
  ld    x,   0x64                                                                  // 0x48A  (0xB64)
  ld    a,   mx                                                                    // 0x48B  (0xEC2)
  add   mx,  0x1                                                                   // 0x48C  (0xC21)
  ldpx  a,   a                                                                     // 0x48D  (0xEE0)
  ld    b,   mx                                                                    // 0x48E  (0xEC6)
  adc   mx,  0x0                                                                   // 0x48F  (0xC60)
  ld    x,   0x62                                                                  // 0x490  (0xB62)
  call  jp_table_0xB00_2                                                           // 0x491  (0x4E3)
  ld    x,   0x62                                                                  // 0x492  (0xB62)
  ld    a,   mx                                                                    // 0x493  (0xEC2)
  ld    x,   0x5F                                                                  // 0x494  (0xB5F)
  ld    mx,  a                                                                     // 0x495  (0xEC8)

label_146:
  ld    x,   0x66                                                                  // 0x496  (0xB66)
  add   mx,  0xF                                                                   // 0x497  (0xC2F)
  ldpx  a,   a                                                                     // 0x498  (0xEE0)
  adc   mx,  0xF                                                                   // 0x499  (0xC6F)
  jp    c,   label_147                                                             // 0x49A  (0x2A8)
  ld    x,   0x6A                                                                  // 0x49B  (0xB6A)
  ld    a,   mx                                                                    // 0x49C  (0xEC2)
  add   mx,  0x2                                                                   // 0x49D  (0xC22)
  ldpx  a,   a                                                                     // 0x49E  (0xEE0)
  ld    b,   mx                                                                    // 0x49F  (0xEC6)
  adc   mx,  0x0                                                                   // 0x4A0  (0xC60)
  ld    x,   0x66                                                                  // 0x4A1  (0xB66)
  call  jp_table_0x980_2                                                           // 0x4A2  (0x4E5)
  ld    x,   0x67                                                                  // 0x4A3  (0xB67)
  ld    a,   mx                                                                    // 0x4A4  (0xEC2)
  and   mx,  0x0                                                                   // 0x4A5  (0xCA0)
  ld    x,   0x70                                                                  // 0x4A6  (0xB70)
  ld    mx,  a                                                                     // 0x4A7  (0xEC8)

label_147:
  ld    x,   0x68                                                                  // 0x4A8  (0xB68)
  ldpx  a,   mx                                                                    // 0x4A9  (0xEE2)
  ldpx  b,   mx                                                                    // 0x4AA  (0xEE6)
  fan   a,   0x1                                                                   // 0x4AB  (0xD81)
  jp    z,   label_148                                                             // 0x4AC  (0x6B2)
  and   a,   0xE                                                                   // 0x4AD  (0xC8E)
  ld    x,   0x6C                                                                  // 0x4AE  (0xB6C)
  add   a,   mx                                                                    // 0x4AF  (0xA82)
  ldpx  a,   a                                                                     // 0x4B0  (0xEE0)
  adc   b,   mx                                                                    // 0x4B1  (0xA96)

label_148:
  ld    x,   0x6C                                                                  // 0x4B2  (0xB6C)
  ldpx  mx,  a                                                                     // 0x4B3  (0xEE8)
  ldpx  mx,  b                                                                     // 0x4B4  (0xEE9)
  ld    x,   0x3A                                                                  // 0x4B5  (0xB3A)
  ldpx  mx,  a                                                                     // 0x4B6  (0xEE8)
  ldpx  mx,  b                                                                     // 0x4B7  (0xEE9)
  ld    x,   0x70                                                                  // 0x4B8  (0xB70)
  fan   mx,  0x8                                                                   // 0x4B9  (0xDA8)
  jp    z,   label_150                                                             // 0x4BA  (0x6CB)
  ld    x,   0x63                                                                  // 0x4BB  (0xB63)
  ld    b,   mx                                                                    // 0x4BC  (0xEC6)
  ld    x,   0x6E                                                                  // 0x4BD  (0xB6E)
  fan   b,   0x2                                                                   // 0x4BE  (0xD92)
  jp    z,   label_149                                                             // 0x4BF  (0x6C1)
  ld    x,   0x6F                                                                  // 0x4C0  (0xB6F)

label_149:
  ld    a,   mx                                                                    // 0x4C1  (0xEC2)
  ld    x,   0x70                                                                  // 0x4C2  (0xB70)
  ld    b,   mx                                                                    // 0x4C3  (0xEC6)
  add   b,   b                                                                     // 0x4C4  (0xA85)
  add   b,   b                                                                     // 0x4C5  (0xA85)
  ld    x,   0x63                                                                  // 0x4C6  (0xB63)
  xor   b,   mx                                                                    // 0x4C7  (0xAE6)
  and   b,   0x8                                                                   // 0x4C8  (0xC98)
  pset  0x9                                                                        // 0x4C9  (0xE49)
  call  label_288                                                                  // 0x4CA  (0x428)

label_150:
  calz  zero_a_xp                                                                  // 0x4CB  (0x5EF)
  ld    x,   0x3B                                                                  // 0x4CC  (0xB3B)
  add   mx,  0x8                                                                   // 0x4CD  (0xC28)
  ld    x,   0x70                                                                  // 0x4CE  (0xB70)
  fan   mx,  0x4                                                                   // 0x4CF  (0xDA4)
  jp    z,   label_150_ret                                                         // 0x4D0  (0x6E2)
  ld    x,   0x63                                                                  // 0x4D1  (0xB63)
  ld    b,   mx                                                                    // 0x4D2  (0xEC6)
  ld    x,   0x6E                                                                  // 0x4D3  (0xB6E)
  fan   b,   0x1                                                                   // 0x4D4  (0xD91)
  jp    z,   label_150_skip_ld                                                     // 0x4D5  (0x6D7)
  ld    x,   0x6F                                                                  // 0x4D6  (0xB6F)

label_150_skip_ld:
  ld    a,   mx                                                                    // 0x4D7  (0xEC2)
  ld    x,   0x70                                                                  // 0x4D8  (0xB70)
  ld    b,   mx                                                                    // 0x4D9  (0xEC6)
  add   b,   b                                                                     // 0x4DA  (0xA85)
  add   b,   b                                                                     // 0x4DB  (0xA85)
  ld    x,   0x63                                                                  // 0x4DC  (0xB63)
  xor   b,   mx                                                                    // 0x4DD  (0xAE6)
  add   b,   b                                                                     // 0x4DE  (0xA85)
  and   b,   0x8                                                                   // 0x4DF  (0xC98)
  
  // Due to zero_a_xp, XP is 0
  pset  0x9                                                                        // 0x4E0  (0xE49)
  call  label_289                                                                  // 0x4E1  (0x439)

label_150_ret:
  ret                                                                              // 0x4E2  (0xFDF)

jp_table_0xB00_2:
  pset  0xB                                                                        // 0x4E3  (0xE4B)
  jpba                                                                             // 0x4E4  (0xFE8)

jp_table_0x980_2:
  pset  0x9                                                                        // 0x4E5  (0xE49)
  jpba                                                                             // 0x4E6  (0xFE8)

label_155:
  ld    x,   0x40                                                                  // 0x4E7  (0xB40)
  ld    a,   0x0                                                                   // 0x4E8  (0xE00)
  pset  0x8                                                                        // 0x4E9  (0xE48)
  call  label_245                                                                  // 0x4EA  (0x40D)
  ld    x,   0xC0                                                                  // 0x4EB  (0xBC0)
  ld    a,   0x0                                                                   // 0x4EC  (0xE00)
  pset  0x8                                                                        // 0x4ED  (0xE48)
  call  label_245                                                                  // 0x4EE  (0x40D)
  calz  zero_a_xp                                                                  // 0x4EF  (0x5EF)
  ld    x,   0x3A                                                                  // 0x4F0  (0xB3A)
  lbpx  mx,  0xC4                                                                  // 0x4F1  (0x9C4)
  pset  0x5                                                                        // 0x4F2  (0xE45)
  call  label_181                                                                  // 0x4F3  (0x4A6)
  ld    x,   0x70                                                                  // 0x4F4  (0xB70)
  ld    a,   0x4                                                                   // 0x4F5  (0xE04)
  pset  0x8                                                                        // 0x4F6  (0xE48)
  call  label_245                                                                  // 0x4F7  (0x40D)
  ld    a,   0x4                                                                   // 0x4F8  (0xE04)
  ld    b,   0x4                                                                   // 0x4F9  (0xE14)
  pset  0xA                                                                        // 0x4FA  (0xE4A)
  call  label_305                                                                  // 0x4FB  (0x4F0)
  pset  0x2                                                                        // 0x4FC  (0xE42)
  jp    label_88                                                                   // 0x4FD  (0x93)
  nop7                                                                             // 0x4FE  (0xFFF)
  nop7                                                                             // 0x4FF  (0xFFF)

label_156:
  calz  copy_video_buf_to_vram                                                     // 0x500  (0x556)
  calz  zero_a_xp                                                                  // 0x501  (0x5EF)
  ld    x,   0x2A                                                                  // 0x502  (0xB2A)
  add   mx,  b                                                                     // 0x503  (0xA89)
  ldpx  a,   a                                                                     // 0x504  (0xEE0)
  adc   mx,  0xF                                                                   // 0x505  (0xC6F)
  jp    c,   label_156                                                             // 0x506  (0x200)
  ret                                                                              // 0x507  (0xFDF)

label_157:
  calz  label_25                                                                   // 0x508  (0x5BB)
  calz  label_38                                                                   // 0x509  (0x5EC)
  calz  label_30                                                                   // 0x50A  (0x5CE)
  call  label_176                                                                  // 0x50B  (0x496)
  pset  0x4                                                                        // 0x50C  (0xE44)
  call  label_145                                                                  // 0x50D  (0x486)
  pset  0x4                                                                        // 0x50E  (0xE44)
  call  copy_buf_and_render_misc                                                   // 0x50F  (0x400)
  ld    b,   0xC                                                                   // 0x510  (0xE1C)
  call  label_156                                                                  // 0x511  (0x400)

label_158:
  ld    x,   0x7C                                                                  // 0x512  (0xB7C)
  cp    mx,  0x0                                                                   // 0x513  (0xDE0)
  jp    nz,  label_159                                                             // 0x514  (0x717)
  pset  0xF                                                                        // 0x515  (0xE4F)
  call  label_391                                                                  // 0x516  (0x4EC)

label_159:
  calz  zero_a_xp                                                                  // 0x517  (0x5EF)
  ld    x,   0xA0                                                                  // 0x518  (0xBA0)
  ldpx  mx,  0x0                                                                   // 0x519  (0xE60)

label_160:
  ld    b,   0xA                                                                   // 0x51A  (0xE1A)
  calz  zero_a_xp                                                                  // 0x51B  (0x5EF)
  ld    a,   0x1                                                                   // 0x51C  (0xE01)
  ld    x,   0x7C                                                                  // 0x51D  (0xB7C)
  cp    mx,  0xF                                                                   // 0x51E  (0xDEF)
  jp    nz,  label_161                                                             // 0x51F  (0x721)
  ld    a,   0x8                                                                   // 0x520  (0xE08)

label_161:
  pset  0x1                                                                        // 0x521  (0xE41)
  call  label_66                                                                   // 0x522  (0x4EC)
  ld    x,   0xA0                                                                  // 0x523  (0xBA0)
  ldpx  a,   mx                                                                    // 0x524  (0xEE2)
  ld    x,   0x75                                                                  // 0x525  (0xB75)
  ldpx  mx,  a                                                                     // 0x526  (0xEE8)
  calz  label_39                                                                   // 0x527  (0x5ED)

label_162:
  calz  zero_a_xp                                                                  // 0x528  (0x5EF)
  ld    x,   0x7C                                                                  // 0x529  (0xB7C)
  cp    mx,  0x0                                                                   // 0x52A  (0xDE0)
  jp    z,   label_158                                                             // 0x52B  (0x612)
  pset  0xF                                                                        // 0x52C  (0xE4F)
  call  label_357                                                                  // 0x52D  (0x400)
  jp    nz,  label_165                                                             // 0x52E  (0x74A)
  pset  0x2                                                                        // 0x52F  (0xE42)
  call  label_94                                                                   // 0x530  (0x4C3)
  push  f                                                                          // 0x531  (0xFCA)
  pop   b                                                                          // 0x532  (0xFD1)
  ld    x,   0x28                                                                  // 0x533  (0xB28)
  cp    mx,  0x3                                                                   // 0x534  (0xDE3)
  cp    mx,  0x5                                                                   // 0x535  (0xDE5)
  jp    nz,  label_163                                                             // 0x536  (0x73A)
  ld    x,   0x29                                                                  // 0x537  (0xB29)
  fan   mx,  0x5                                                                   // 0x538  (0xDA5)
  jp    nz,  label_166                                                             // 0x539  (0x74D)

label_163:
  fan   b,   0x1                                                                   // 0x53A  (0xD91)
  jp    nz,  label_159                                                             // 0x53B  (0x717)
  fan   b,   0x2                                                                   // 0x53C  (0xD92)
  jp    nz,  label_164                                                             // 0x53D  (0x743)
  calz  label_39                                                                   // 0x53E  (0x5ED)
  calz  clear_page_0x100                                                           // 0x53F  (0x540)
  call  label_176                                                                  // 0x540  (0x496)
  calz  label_13                                                                   // 0x541  (0x552)
  jp    label_162                                                                  // 0x542  (0x28)

label_164:
  calz  zero_b_xp                                                                  // 0x543  (0x5F2)
  ld    x,   0xA0                                                                  // 0x544  (0xBA0)
  ld    mx,  a                                                                     // 0x545  (0xEC8)
  add   a,   a                                                                     // 0x546  (0xA80)
  adc   b,   b                                                                     // 0x547  (0xA95)
  pset  0x7                                                                        // 0x548  (0xE47)
  jpba                                                                             // 0x549  (0xFE8)

label_165:
  pset  0x3                                                                        // 0x54A  (0xE43)
  call  label_101                                                                  // 0x54B  (0x407)
  jp    label_159                                                                  // 0x54C  (0x17)

label_166:
  ld    x,   0x7B                                                                  // 0x54D  (0xB7B)
  xor   mx,  0xF                                                                   // 0x54E  (0xD2F)
  ld    b,   0xF                                                                   // 0x54F  (0xE1F)
  ld    y,   0x97                                                                  // 0x550  (0x897)
  calz  clear_0x32_store_yhl                                                       // 0x551  (0x5C2)
  jp    label_159                                                                  // 0x552  (0x17)

label_167:
  calz  label_25                                                                   // 0x553  (0x5BB)
  ld    a,   0x0                                                                   // 0x554  (0xE00)
  calz  label_39                                                                   // 0x555  (0x5ED)
  calz  clear_page_0x100                                                           // 0x556  (0x540)
  calz  one_a_xp                                                                   // 0x557  (0x5F5)
  ld    x,   0xE0                                                                  // 0x558  (0xBE0)
  ld    a,   0xC                                                                   // 0x559  (0xE0C)
  ld    b,   0x0                                                                   // 0x55A  (0xE10)
  pset  0x7                                                                        // 0x55B  (0xE47)
  call  misc_render                                                                // 0x55C  (0x4A5)
  ld    a,   0xD                                                                   // 0x55D  (0xE0D)
  ld    b,   0x0                                                                   // 0x55E  (0xE10)
  pset  0x7                                                                        // 0x55F  (0xE47)
  call  misc_render                                                                // 0x560  (0x4A5)
  calz  zero_a_xp                                                                  // 0x561  (0x5EF)
  ld    x,   0x3C                                                                  // 0x562  (0xB3C)
  ld    mx,  0x0                                                                   // 0x563  (0xE20)
  ld    x,   0x10                                                                  // 0x564  (0xB10)
  lbpx  mx,  0x0                                                                   // 0x565  (0x900)
  ld    x,   0x3F                                                                  // 0x566  (0xB3F)
  ld    mx,  0x6                                                                   // 0x567  (0xE26)
  call  label_175                                                                  // 0x568  (0x491)

label_168:
  calz  copy_0x026_7_to_8_9                                                        // 0x569  (0x521)
  cp    a,   0x0                                                                   // 0x56A  (0xDC0)
  jp    nz,  label_168                                                             // 0x56B  (0x769)

label_169:
  call  label_175                                                                  // 0x56C  (0x491)

label_170:
  calz  copy_0x026_7_to_8_9                                                        // 0x56D  (0x521)
  fan   mx,  0x1                                                                   // 0x56E  (0xDA1)
  jp    nz,  label_174                                                             // 0x56F  (0x786)
  fan   mx,  0x2                                                                   // 0x570  (0xDA2)
  jp    z,   label_171                                                             // 0x571  (0x676)
  calz  label_25                                                                   // 0x572  (0x5BB)
  calz  label_35                                                                   // 0x573  (0x5E2)
  ld    x,   0x2E                                                                  // 0x574  (0xB2E)
  ld    mx,  0xF                                                                   // 0x575  (0xE2F)

label_171:
  ld    x,   0x29                                                                  // 0x576  (0xB29)
  fan   mx,  0x4                                                                   // 0x577  (0xDA4)
  jp    z,   label_172                                                             // 0x578  (0x682)
  calz  label_25                                                                   // 0x579  (0x5BB)
  ld    x,   0x14                                                                  // 0x57A  (0xB14)
  ldpx  a,   mx                                                                    // 0x57B  (0xEE2)
  ldpx  b,   mx                                                                    // 0x57C  (0xEE6)
  and   b,   0x1                                                                   // 0x57D  (0xC91)
  ld    x,   0x14                                                                  // 0x57E  (0xB14)
  pset  0x1                                                                        // 0x57F  (0xE41)
  call  label_67                                                                   // 0x580  (0x4F4)
  jp    label_173                                                                  // 0x581  (0x85)

label_172:
  ld    x,   0x2E                                                                  // 0x582  (0xB2E)
  cp    mx,  0x0                                                                   // 0x583  (0xDE0)
  jp    z,   label_170                                                             // 0x584  (0x66D)

label_173:
  jp    label_169                                                                  // 0x585  (0x6C)

label_174:
  calz  label_25                                                                   // 0x586  (0x5BB)
  ld    x,   0x3F                                                                  // 0x587  (0xB3F)
  ld    mx,  0x0                                                                   // 0x588  (0xE20)
  ld    x,   0x15                                                                  // 0x589  (0xB15)
  cp    mx,  0x2                                                                   // 0x58A  (0xDE2)
  pset  0x9                                                                        // 0x58B  (0xE49)
  jp    nc,  label_294                                                             // 0x58C  (0x37F)
  ld    x,   0x3C                                                                  // 0x58D  (0xB3C)
  ld    mx,  0xF                                                                   // 0x58E  (0xE2F)
  pset  0x2                                                                        // 0x58F  (0xE42)
  jp    label_88                                                                   // 0x590  (0x93)

label_175:
  calz  label_30                                                                   // 0x591  (0x5CE)
  lbpx  mx,  0xC4                                                                  // 0x592  (0x9C4)
  call  label_181                                                                  // 0x593  (0x4A6)
  calz  copy_video_buf_to_vram                                                     // 0x594  (0x556)
  ret                                                                              // 0x595  (0xFDF)

label_176:
  calz  check_0x04A_highbit                                                        // 0x596  (0x5B3)
  jp    nz,  label_178                                                             // 0x597  (0x79E)
  calz  bit_high_at_0x048                                                          // 0x598  (0x5FD)
  jp    nz,  label_177                                                             // 0x599  (0x79C)
  ld    a,   0x1                                                                   // 0x59A  (0xE01)
  jp    label_179                                                                  // 0x59B  (0x9F)

label_177:
  ld    a,   0x9                                                                   // 0x59C  (0xE09)
  jp    label_179                                                                  // 0x59D  (0x9F)

label_178:
  ld    a,   0x3                                                                   // 0x59E  (0xE03)

label_179:
  ld    x,   0x5E                                                                  // 0x59F  (0xB5E)
  cp    mx,  a                                                                     // 0x5A0  (0xF08)
  jp    z,   label_180                                                             // 0x5A1  (0x6A5)
  ld    mx,  a                                                                     // 0x5A2  (0xEC8)
  pset  0x4                                                                        // 0x5A3  (0xE44)
  call  label_142                                                                  // 0x5A4  (0x465)

label_180:
  ret                                                                              // 0x5A5  (0xFDF)

label_181:
  calz  zero_a_xp                                                                  // 0x5A6  (0x5EF)
  ld    x,   0x2E                                                                  // 0x5A7  (0xB2E)
  calz  clear_0x07D                                                                // 0x5A8  (0x512)
  ld    mx,  0x0                                                                   // 0x5A9  (0xE20)
  ld    x,   0x10                                                                  // 0x5AA  (0xB10)
  ldpx  a,   mx                                                                    // 0x5AB  (0xEE2)
  ld    m4,  a                                                                     // 0x5AC  (0xF84)
  ldpx  a,   mx                                                                    // 0x5AD  (0xEE2)
  ld    m5,  a                                                                     // 0x5AE  (0xF85)
  ldpx  a,   mx                                                                    // 0x5AF  (0xEE2)
  ld    m6,  a                                                                     // 0x5B0  (0xF86)
  ldpx  a,   mx                                                                    // 0x5B1  (0xEE2)
  ld    m7,  a                                                                     // 0x5B2  (0xF87)
  ldpx  a,   mx                                                                    // 0x5B3  (0xEE2)
  ldpx  b,   mx                                                                    // 0x5B4  (0xEE6)
  calz  set_f_0x07D                                                                // 0x5B5  (0x509)
  ld    x,   0x8                                                                   // 0x5B6  (0xB08)
  call  label_184                                                                  // 0x5B7  (0x4E3)
  ld    x,   0x3A                                                                  // 0x5B8  (0xB3A)
  ldpx  a,   mx                                                                    // 0x5B9  (0xEE2)
  ld    xh,  mx                                                                    // 0x5BA  (0xE86)
  ld    xl,  a                                                                     // 0x5BB  (0xE88)
  calz  one_a_xp                                                                   // 0x5BC  (0x5F5)
  ld    a,   m9                                                                    // 0x5BD  (0xFA9)
  rrc   a                                                                          // 0x5BE  (0xE8C)
  rrc   a                                                                          // 0x5BF  (0xE8C)
  rrc   a                                                                          // 0x5C0  (0xE8C)
  and   a,   0x1                                                                   // 0x5C1  (0xC81)
  or    a,   0xA                                                                   // 0x5C2  (0xCCA)
  ld    b,   0x0                                                                   // 0x5C3  (0xE10)
  pset  0x7                                                                        // 0x5C4  (0xE47)
  call  misc_render                                                                // 0x5C5  (0x4A5)
  pset  0x7                                                                        // 0x5C6  (0xE47)
  call  clear_16_addrs                                                             // 0x5C7  (0x4B8)
  rst   f,   0xE                                                                   // 0x5C8  (0xF5E)
  adc   xh,  0x6                                                                   // 0x5C9  (0xA06)
  ld    a,   m9                                                                    // 0x5CA  (0xFA9)
  and   a,   0x3                                                                   // 0x5CB  (0xC83)
  // If m9 & 0x3 != 0, render the clock data
  jp    nz,  render_clock_values                                                   // 0x5CC  (0x7D0)
  // Otherwise, clear 8 mem addresses and skip first render call
  pset  0x7                                                                        // 0x5CD  (0xE47)
  call  clear_8_addrs_ret                                                          // 0x5CE  (0x4BC)
  // If we don't 
  jp    render_clock_values_skip_first                                             // 0x5CF  (0xD1)

render_clock_values:
  call  setup_addr_and_render_clock                                                // 0x5D0  (0x4F3)

render_clock_values_skip_first:
  lbpx  mx,  0x0                                                                   // 0x5D1  (0x900)
  ld    a,   m8                                                                    // 0x5D2  (0xFA8)
  call  setup_addr_and_render_clock                                                // 0x5D3  (0x4F3)
  lbpx  mx,  0x0                                                                   // 0x5D4  (0x900)
  lbpx  mx,  0x22                                                                  // 0x5D5  (0x922)
  lbpx  mx,  0x0                                                                   // 0x5D6  (0x900)
  ld    a,   m7                                                                    // 0x5D7  (0xFA7)
  call  setup_addr_and_render_clock                                                // 0x5D8  (0x4F3)
  lbpx  mx,  0x0                                                                   // 0x5D9  (0x900)
  ld    a,   m6                                                                    // 0x5DA  (0xFA6)
  call  setup_addr_and_render_clock                                                // 0x5DB  (0x4F3)
  lbpx  mx,  0x0                                                                   // 0x5DC  (0x900)
  lbpx  mx,  0x0                                                                   // 0x5DD  (0x900)
  ld    a,   m5                                                                    // 0x5DE  (0xFA5)
  call  render_clock_with_b_0                                                      // 0x5DF  (0x4EF)
  lbpx  mx,  0x0                                                                   // 0x5E0  (0x900)
  ld    a,   m4                                                                    // 0x5E1  (0xFA4)
  jp    render_clock_with_b_0                                                      // 0x5E2  (0xEF)

label_184:
  cp    b,   0x1                                                                   // 0x5E3  (0xDD1)
  jp    c,   label_186                                                             // 0x5E4  (0x2E9)
  jp    nz,  label_185                                                             // 0x5E5  (0x7E8)
  cp    a,   0x8                                                                   // 0x5E6  (0xDC8)
  jp    c,   label_186                                                             // 0x5E7  (0x2E9)

label_185:
  retd  0x0                                                                        // 0x5E8  (0x100)

label_186:
  add   a,   0x6                                                                   // 0x5E9  (0xC06)
  ld    m0,  a                                                                     // 0x5EA  (0xF80)
  adc   b,   0xE                                                                   // 0x5EB  (0xC5E)
  ld    m1,  b                                                                     // 0x5EC  (0xF91)
  ld    a,   0x5                                                                   // 0x5ED  (0xE05)
  jp    render_clock_page                                                          // 0x5EE  (0xFB)

//
// Render clock graphics
// Expects A to be set to the graphic to show
// B will be set to 0, and incremented as necessary
//
render_clock_with_b_0:
  ld    b,   0x0                                                                   // 0x5EF  (0xE10)
  add   a,   0xA                                                                   // 0x5F0  (0xC0A)
  adc   b,   0x0                                                                   // 0x5F1  (0xC50)
  jp    skip_ld_b_187                                                              // 0x5F2  (0xF4)

//
// Render clock graphics
// Does not increment B
//
setup_addr_and_render_clock:
  ld    b,   0x0                                                                   // 0x5F3  (0xE10)

skip_ld_b_187:
  // Set up image address
  add   a,   a                                                                     // 0x5F4  (0xA80)
  // When 2A overflows, 2B + 1
  adc   b,   b                                                                     // 0x5F5  (0xA95)
  add   a,   a                                                                     // 0x5F6  (0xA80)
  adc   b,   b                                                                     // 0x5F7  (0xA95)
  ld    m0,  a                                                                     // 0x5F8  (0xF80)
  ld    m1,  b                                                                     // 0x5F9  (0xF91)
  ld    a,   0x5                                                                   // 0x5FA  (0xE05)

// Renders assets from the clock page, both incoming paths
render_clock_page:
  // Both call paths, a = 5
  // render page calc: (5 & 7) * 4 = 5 * 4 = (5 + 5) * 2 = 0xA + 0xA = 0x4
  // m2 = 4
  // jpba will be b = 1, a = 4
  // Jump to 0x15 page
  ld    m2,  a                                                                     // 0x5FB  (0xF82)
  pset  0x0                                                                        // 0x5FC  (0xE40)
  jp    render_asset                                                               // 0x5FD  (0x0)
  nop7                                                                             // 0x5FE  (0xFFF)
  nop7                                                                             // 0x5FF  (0xFFF)

label_191:
  calz  check_0x04A_highbit                                                        // 0x600  (0x5B3)
  jp    nz,  label_193                                                             // 0x601  (0x71C)
  calz  zero_a_xp_and_bit_high_at_0x048                                            // 0x602  (0x5FB)
  jp    nz,  label_192                                                             // 0x603  (0x706)
  pset  0x6                                                                        // 0x604  (0xE46)
  jp    label_194                                                                  // 0x605  (0x1E)

label_192:
  and   mx,  0x7                                                                   // 0x606  (0xCA7)
  ld    a,   0x8                                                                   // 0x607  (0xE08)
  ld    b,   0x5                                                                   // 0x608  (0xE15)
  ld    y,   0x3                                                                   // 0x609  (0x803)
  pset  0x8                                                                        // 0x60A  (0xE48)
  call  label_273                                                                  // 0x60B  (0x4A9)
  ld    a,   0x2                                                                   // 0x60C  (0xE02)
  ld    yp,  a                                                                     // 0x60D  (0xE90)
  ld    y,   0x3B                                                                  // 0x60E  (0x83B)
  calz  zero_a_xp                                                                  // 0x60F  (0x5EF)
  ld    x,   0x48                                                                  // 0x610  (0xB48)
  or    mx,  0x8                                                                   // 0x611  (0xCE8)
  add   mx,  my                                                                    // 0x612  (0xA8B)
  fan   mx,  0x8                                                                   // 0x613  (0xDA8)
  jp    nz,  label_193                                                             // 0x614  (0x71C)
  ld    a,   0x2                                                                   // 0x615  (0xE02)
  ld    xp,  a                                                                     // 0x616  (0xE80)
  ld    x,   0xD                                                                   // 0x617  (0xB0D)
  ld    y,   0x38                                                                  // 0x618  (0x838)
  calz  clear_0x07D                                                                // 0x619  (0x512)
  calz  copy_3_mx_my_ret                                                           // 0x61A  (0x599)
  calz  set_f_0x07D                                                                // 0x61B  (0x509)

label_193:
  pset  0x5                                                                        // 0x61C  (0xE45)
  jp    label_160                                                                  // 0x61D  (0x1A)

label_194:
  ld    a,   0x6                                                                   // 0x61E  (0xE06)
  ld    b,   0x5                                                                   // 0x61F  (0xE15)
  pset  0x8                                                                        // 0x620  (0xE48)
  call  label_272                                                                  // 0x621  (0x4A8)

label_195:
  pset  0x5                                                                        // 0x622  (0xE45)
  jp    label_160                                                                  // 0x623  (0x1A)

label_196:
  calz  check_0x04A_highbit                                                        // 0x624  (0x5B3)
  jp    nz,  label_195                                                             // 0x625  (0x722)

label_197:
  calz  zero_a_xp_and_bit_high_at_0x048                                            // 0x626  (0x5FB)
  jp    nz,  label_194                                                             // 0x627  (0x71E)
  ld    a,   0x2                                                                   // 0x628  (0xE02)
  ld    yp,  a                                                                     // 0x629  (0xE90)
  ld    y,   0x9                                                                   // 0x62A  (0x809)
  cp    my,  0x0                                                                   // 0x62B  (0xDF0)
  jp    nz,  label_194                                                             // 0x62C  (0x71E)
  ld    x,   0x5E                                                                  // 0x62D  (0xB5E)
  ld    mx,  0x5                                                                   // 0x62E  (0xE25)
  pset  0x4                                                                        // 0x62F  (0xE44)
  call  label_142                                                                  // 0x630  (0x465)
  calz  clear_page_0x100                                                           // 0x631  (0x540)
  pset  0x4                                                                        // 0x632  (0xE44)
  call  label_145                                                                  // 0x633  (0x486)
  pset  0x4                                                                        // 0x634  (0xE44)
  call  copy_buf_and_render_misc                                                   // 0x635  (0x400)
  calz  zero_a_xp                                                                  // 0x636  (0x5EF)
  ld    x,   0x90                                                                  // 0x637  (0xB90)
  lbpx  mx,  0xFF                                                                  // 0x638  (0x9FF)
  lbpx  mx,  0x1C                                                                  // 0x639  (0x91C)
  lbpx  mx,  0xFF                                                                  // 0x63A  (0x9FF)
  lbpx  mx,  0x1C                                                                  // 0x63B  (0x91C)
  lbpx  mx,  0x1D                                                                  // 0x63C  (0x91D)
  lbpx  mx,  0xFF                                                                  // 0x63D  (0x9FF)
  lbpx  mx,  0x1D                                                                  // 0x63E  (0x91D)
  lbpx  mx,  0xFF                                                                  // 0x63F  (0x9FF)
  ld    y,   0xD6                                                                  // 0x640  (0x8D6)
  calz  if_0x7B_set_clear_0x32_store_yhl_set_0x059_to_0xF                          // 0x641  (0x5BC)
  calz  label_34                                                                   // 0x642  (0x5DE)
  calz  copy_video_buf_to_vram                                                     // 0x643  (0x556)
  ld    x,   0xD                                                                   // 0x644  (0xB0D)
  calz  copy_xhl_to_0x022_or_loop_0x023                                            // 0x645  (0x53C)
  ld    b,   0xC                                                                   // 0x646  (0xE1C)
  pset  0x5                                                                        // 0x647  (0xE45)
  call  label_156                                                                  // 0x648  (0x400)
  ld    x,   0x82                                                                  // 0x649  (0xB82)
  ldpx  mx,  0x5                                                                   // 0x64A  (0xE65)
  ldpx  mx,  0x0                                                                   // 0x64B  (0xE60)

label_198:
  calz  zero_a_xp                                                                  // 0x64C  (0x5EF)
  ld    a,   0x2                                                                   // 0x64D  (0xE02)
  ld    yp,  a                                                                     // 0x64E  (0xE90)
  ld    x,   0x81                                                                  // 0x64F  (0xB81)
  ldpx  mx,  0x0                                                                   // 0x650  (0xE60)
  ld    y,   0x46                                                                  // 0x651  (0x846)
  ld    x,   0x80                                                                  // 0x652  (0xB80)
  ldpx  mx,  my                                                                    // 0x653  (0xEEB)
  ld    x,   0x84                                                                  // 0x654  (0xB84)
  ld    mx,  0x8                                                                   // 0x655  (0xE28)
  ld    y,   0x45                                                                  // 0x656  (0x845)
  ld    a,   my                                                                    // 0x657  (0xEC3)
  pset  0x9                                                                        // 0x658  (0xE49)
  call  label_282                                                                  // 0x659  (0x400)
  jp    c,   label_199                                                             // 0x65A  (0x260)
  ld    y,   0x47                                                                  // 0x65B  (0x847)
  ld    x,   0x80                                                                  // 0x65C  (0xB80)
  ldpx  mx,  my                                                                    // 0x65D  (0xEEB)
  ld    x,   0x84                                                                  // 0x65E  (0xB84)
  ld    mx,  0x0                                                                   // 0x65F  (0xE20)

label_199:
  ld    x,   0x5E                                                                  // 0x660  (0xB5E)
  ld    mx,  0x5                                                                   // 0x661  (0xE25)
  pset  0x4                                                                        // 0x662  (0xE44)
  call  label_142                                                                  // 0x663  (0x465)
  calz  copy_0x026_7_to_8_9                                                        // 0x664  (0x521)
  ld    x,   0x57                                                                  // 0x665  (0xB57)
  ld    mx,  0xF                                                                   // 0x666  (0xE2F)

label_200:
  ld    y,   0x97                                                                  // 0x667  (0x897)
  calz  if_0x7B_set_clear_0x32_store_yhl_set_0x059_to_0xF                          // 0x668  (0x5BC)
  calz  clear_page_0x100                                                           // 0x669  (0x540)
  pset  0x4                                                                        // 0x66A  (0xE44)
  call  label_145                                                                  // 0x66B  (0x486)
  call  label_211                                                                  // 0x66C  (0x4D4)
  calz  calz_copy_buf_and_render_misc                                              // 0x66D  (0x554)
  calz  copy_0x026_7_to_8_9                                                        // 0x66E  (0x521)
  fan   mx,  0x1                                                                   // 0x66F  (0xDA1)
  jp    nz,  label_207                                                             // 0x670  (0x7C5)
  ld    x,   0x57                                                                  // 0x671  (0xB57)
  cp    mx,  0x0                                                                   // 0x672  (0xDE0)
  jp    z,   label_207                                                             // 0x673  (0x6C5)
  ld    x,   0x81                                                                  // 0x674  (0xB81)
  cp    mx,  0x0                                                                   // 0x675  (0xDE0)
  jp    nz,  label_201                                                             // 0x676  (0x77A)
  fan   b,   0x6                                                                   // 0x677  (0xD96)
  jp    z,   label_200                                                             // 0x678  (0x667)
  ld    mx,  b                                                                     // 0x679  (0xEC9)

label_201:
  ld    x,   0x80                                                                  // 0x67A  (0xB80)
  add   mx,  0xF                                                                   // 0x67B  (0xC2F)
  jp    nz,  label_200                                                             // 0x67C  (0x767)
  calz  label_25                                                                   // 0x67D  (0x5BB)
  calz  clear_page_0x100                                                           // 0x67E  (0x540)
  calz  zero_a_xp                                                                  // 0x67F  (0x5EF)
  ld    x,   0x84                                                                  // 0x680  (0xB84)
  ld    b,   mx                                                                    // 0x681  (0xEC6)
  ld    x,   0x81                                                                  // 0x682  (0xB81)
  fan   mx,  0x4                                                                   // 0x683  (0xDA4)
  jp    z,   label_202                                                             // 0x684  (0x686)
  xor   b,   0x8                                                                   // 0x685  (0xD18)

label_202:
  ld    x,   0x3A                                                                  // 0x686  (0xB3A)
  lbpx  mx,  0x10                                                                  // 0x687  (0x910)
  pset  0x3                                                                        // 0x688  (0xE43)
  call  label_128                                                                  // 0x689  (0x4EE)
  call  label_211                                                                  // 0x68A  (0x4D4)
  calz  calz_copy_buf_and_render_misc                                              // 0x68B  (0x554)
  ld    x,   0x29                                                                  // 0x68C  (0xB29)
  calz  copy_xhl_to_0x022_or_loop_0x023                                            // 0x68D  (0x53C)
  calz  zero_a_xp                                                                  // 0x68E  (0x5EF)
  ld    x,   0x84                                                                  // 0x68F  (0xB84)
  cp    mx,  0x0                                                                   // 0x690  (0xDE0)
  jp    z,   label_203                                                             // 0x691  (0x696)
  ld    x,   0x83                                                                  // 0x692  (0xB83)
  add   mx,  0x1                                                                   // 0x693  (0xC21)
  call  label_208                                                                  // 0x694  (0x4C8)
  jp    label_204                                                                  // 0x695  (0x97)

label_203:
  call  label_209                                                                  // 0x696  (0x4CD)

label_204:
  calz  zero_a_xp                                                                  // 0x697  (0x5EF)
  ld    x,   0x82                                                                  // 0x698  (0xB82)
  add   mx,  0xF                                                                   // 0x699  (0xC2F)
  jp    nz,  label_198                                                             // 0x69A  (0x74C)
  ld    x,   0x90                                                                  // 0x69B  (0xB90)
  pset  0xC                                                                        // 0x69C  (0xE4C)
  call  label_334                                                                  // 0x69D  (0x4F5)
  ld    x,   0x83                                                                  // 0x69E  (0xB83)
  ld    a,   mx                                                                    // 0x69F  (0xEC2)
  ld    x,   0x98                                                                  // 0x6A0  (0xB98)
  ld    mx,  a                                                                     // 0x6A1  (0xEC8)
  ld    b,   0x5                                                                   // 0x6A2  (0xE15)
  sub   b,   a                                                                     // 0x6A3  (0xAA4)
  ld    x,   0x9C                                                                  // 0x6A4  (0xB9C)
  ld    mx,  b                                                                     // 0x6A5  (0xEC9)
  ld    y,   0xE5                                                                  // 0x6A6  (0x8E5)
  calz  if_0x7B_set_clear_0x32_store_yhl_set_0x059_to_0xF                          // 0x6A7  (0x5BC)
  calz  label_34                                                                   // 0x6A8  (0x5DE)
  calz  copy_video_buf_to_vram                                                     // 0x6A9  (0x556)
  ld    x,   0x52                                                                  // 0x6AA  (0xB52)
  calz  copy_xhl_to_0x022_or_loop_0x023                                            // 0x6AB  (0x53C)
  calz  zero_a_xp                                                                  // 0x6AC  (0x5EF)
  ld    x,   0x83                                                                  // 0x6AD  (0xB83)
  cp    mx,  0x3                                                                   // 0x6AE  (0xDE3)
  jp    c,   label_205                                                             // 0x6AF  (0x2B5)
  ld    x,   0x41                                                                  // 0x6B0  (0xB41)
  pset  0xC                                                                        // 0x6B1  (0xE4C)
  call  label_331                                                                  // 0x6B2  (0x4E5)
  call  label_208                                                                  // 0x6B3  (0x4C8)
  jp    label_206                                                                  // 0x6B4  (0xB6)

label_205:
  call  label_209                                                                  // 0x6B5  (0x4CD)

label_206:
  calz  zero_a_xp                                                                  // 0x6B6  (0x5EF)
  ld    x,   0x46                                                                  // 0x6B7  (0xB46)
  set   f,   0x4                                                                   // 0x6B8  (0xF44)
  add   mx,  0x9                                                                   // 0x6B9  (0xC29)
  ldpx  a,   a                                                                     // 0x6BA  (0xEE0)
  adc   mx,  0x9                                                                   // 0x6BB  (0xC69)
  rst   f,   0xB                                                                   // 0x6BC  (0xF5B)
  pset  0x6                                                                        // 0x6BD  (0xE46)
  call  label_214                                                                  // 0x6BE  (0x4E5)
  ld    x,   0x29                                                                  // 0x6BF  (0xB29)
  fan   mx,  0x1                                                                   // 0x6C0  (0xDA1)
  jp    nz,  label_207                                                             // 0x6C1  (0x7C5)
  pset  0xF                                                                        // 0x6C2  (0xE4F)
  call  label_357                                                                  // 0x6C3  (0x400)
  jp    z,   label_197                                                             // 0x6C4  (0x626)

label_207:
  calz  label_25                                                                   // 0x6C5  (0x5BB)
  pset  0x5                                                                        // 0x6C6  (0xE45)
  jp    label_159                                                                  // 0x6C7  (0x17)

label_208:
  ld    y,   0x83                                                                  // 0x6C8  (0x883)
  calz  if_0x7B_set_clear_0x32_store_yhl_set_0x059_to_0xF                          // 0x6C9  (0x5BC)
  ld    a,   0x7                                                                   // 0x6CA  (0xE07)
  ld    y,   0x6                                                                   // 0x6CB  (0x806)
  jp    label_210                                                                  // 0x6CC  (0xD1)

label_209:
  ld    y,   0x9E                                                                  // 0x6CD  (0x89E)
  calz  if_0x7B_set_clear_0x32_store_yhl_set_0x059_to_0xF                          // 0x6CE  (0x5BC)
  ld    a,   0x8                                                                   // 0x6CF  (0xE08)
  ld    y,   0x3                                                                   // 0x6D0  (0x803)

label_210:
  ld    b,   0x5                                                                   // 0x6D1  (0xE15)
  pset  0x8                                                                        // 0x6D2  (0xE48)
  jp    label_273                                                                  // 0x6D3  (0xA9)

label_211:
  calz  zero_a_xp                                                                  // 0x6D4  (0x5EF)
  ld    x,   0x81                                                                  // 0x6D5  (0xB81)
  cp    mx,  0x0                                                                   // 0x6D6  (0xDE0)
  jp    z,   label_213                                                             // 0x6D7  (0x6E4)
  ld    b,   mx                                                                    // 0x6D8  (0xEC6)
  ld    x,   0xB0                                                                  // 0x6D9  (0xBB0)
  ld    a,   0x7                                                                   // 0x6DA  (0xE07)
  fan   b,   0x4                                                                   // 0x6DB  (0xD94)
  jp    z,   label_212                                                             // 0x6DC  (0x6DF)
  ld    x,   0x80                                                                  // 0x6DD  (0xB80)
  ld    a,   0x6                                                                   // 0x6DE  (0xE06)

label_212:
  ld    b,   0x1                                                                   // 0x6DF  (0xE11)
  ld    xp,  b                                                                     // 0x6E0  (0xE81)
  ld    b,   0x2                                                                   // 0x6E1  (0xE12)
  pset  0x7                                                                        // 0x6E2  (0xE47)
  call  misc_render                                                                // 0x6E3  (0x4A5)

label_213:
  ret                                                                              // 0x6E4  (0xFDF)

label_214:
  calz  zero_a_xp                                                                  // 0x6E5  (0x5EF)
  ld    a,   0x2                                                                   // 0x6E6  (0xE02)
  ld    yp,  a                                                                     // 0x6E7  (0xE90)
  ld    y,   0x3D                                                                  // 0x6E8  (0x83D)
  call  label_218                                                                  // 0x6E9  (0x4F6)
  jp    c,   label_215                                                             // 0x6EA  (0x2F0)
  ld    y,   0x3F                                                                  // 0x6EB  (0x83F)
  call  label_218                                                                  // 0x6EC  (0x4F6)
  jp    c,   label_217                                                             // 0x6ED  (0x2F5)
  ld    y,   0x3E                                                                  // 0x6EE  (0x83E)
  jp    label_216                                                                  // 0x6EF  (0xF1)

label_215:
  ld    y,   0x3C                                                                  // 0x6F0  (0x83C)

label_216:
  ld    x,   0x46                                                                  // 0x6F1  (0xB46)
  calz  clear_0x07D                                                                // 0x6F2  (0x512)
  calz  copy_2_mx_my_ret                                                           // 0x6F3  (0x59B)
  calz  set_f_0x07D                                                                // 0x6F4  (0x509)

label_217:
  ret                                                                              // 0x6F5  (0xFDF)

label_218:
  ld    x,   0x47                                                                  // 0x6F6  (0xB47)
  cp    mx,  my                                                                    // 0x6F7  (0xF0B)
  jp    c,   label_219                                                             // 0x6F8  (0x2FD)
  jp    nz,  label_219                                                             // 0x6F9  (0x7FD)
  ld    x,   0x46                                                                  // 0x6FA  (0xB46)
  adc   yl,  0xF                                                                   // 0x6FB  (0xA3F)
  cp    mx,  my                                                                    // 0x6FC  (0xF0B)

label_219:
  ret                                                                              // 0x6FD  (0xFDF)
  nop7                                                                             // 0x6FE  (0xFFF)
  nop7                                                                             // 0x6FF  (0xFFF)
  
// Unclear what points to this jump table
  pset  0x4                                                                        // 0x700  (0xE44)
  jp    label_155                                                                  // 0x701  (0xE7)
  pset  0x7                                                                        // 0x702  (0xE47)
  jp    label_220                                                                  // 0x703  (0x10)
  pset  0xA                                                                        // 0x704  (0xE4A)
  jp    label_297                                                                  // 0x705  (0xBE)
  pset  0x6                                                                        // 0x706  (0xE46)
  jp    label_196                                                                  // 0x707  (0x24)
  pset  0x6                                                                        // 0x708  (0xE46)
  jp    label_191                                                                  // 0x709  (0x0)
  pset  0xD                                                                        // 0x70A  (0xE4D)
  jp    label_336                                                                  // 0x70B  (0x7E)
  pset  0x8                                                                        // 0x70C  (0xE48)
  jp    label_247                                                                  // 0x70D  (0x14)
  pset  0xA                                                                        // 0x70E  (0xE4A)
  jp    label_301                                                                  // 0x70F  (0xDA)

label_220:
  calz  check_0x04A_highbit                                                        // 0x710  (0x5B3)
  jp    nz,  label_222                                                             // 0x711  (0x720)

label_221:
  calz  zero_a_xp                                                                  // 0x712  (0x5EF)
  ld    x,   0x73                                                                  // 0x713  (0xB73)
  ld    a,   mx                                                                    // 0x714  (0xEC2)
  ld    x,   0x78                                                                  // 0x715  (0xB78)
  ld    mx,  a                                                                     // 0x716  (0xEC8)
  ld    x,   0x90                                                                  // 0x717  (0xB90)
  pset  0xB                                                                        // 0x718  (0xE4B)
  call  label_308                                                                  // 0x719  (0x4E8)
  ld    b,   0xA                                                                   // 0x71A  (0xE1A)
  pset  0xE                                                                        // 0x71B  (0xE4E)
  call  label_352                                                                  // 0x71C  (0x45A)
  jp    nc,  label_223                                                             // 0x71D  (0x322)
  pset  0x5                                                                        // 0x71E  (0xE45)
  jp    nz,  label_159                                                             // 0x71F  (0x717)

label_222:
  pset  0x5                                                                        // 0x720  (0xE45)
  jp    label_160                                                                  // 0x721  (0x1A)

label_223:
  calz  zero_b_xp                                                                  // 0x722  (0x5F2)
  ld    x,   0x73                                                                  // 0x723  (0xB73)
  ldpx  mx,  a                                                                     // 0x724  (0xEE8)
  cp    a,   0x0                                                                   // 0x725  (0xDC0)
  jp    nz,  label_224                                                             // 0x726  (0x739)
  ld    y,   0xC                                                                   // 0x727  (0x80C)
  calz  bit_high_at_0x048                                                          // 0x728  (0x5FD)
  jp    nz,  label_228                                                             // 0x729  (0x751)
  ld    a,   0x2                                                                   // 0x72A  (0xE02)
  ld    xp,  a                                                                     // 0x72B  (0xE80)
  ld    x,   0x9                                                                   // 0x72C  (0xB09)
  cp    mx,  0x0                                                                   // 0x72D  (0xDE0)
  jp    nz,  label_228                                                             // 0x72E  (0x751)
  calz  zero_a_xp                                                                  // 0x72F  (0x5EF)
  ld    x,   0x40                                                                  // 0x730  (0xB40)
  cp    mx,  0xF                                                                   // 0x731  (0xDEF)
  jp    z,   label_228                                                             // 0x732  (0x651)
  pset  0xC                                                                        // 0x733  (0xE4C)
  call  label_331                                                                  // 0x734  (0x4E5)
  ld    a,   0x1                                                                   // 0x735  (0xE01)
  call  label_230                                                                  // 0x736  (0x456)
  ld    y,   0x8                                                                   // 0x737  (0x808)
  jp    label_226                                                                  // 0x738  (0x49)

label_224:
  ld    x,   0x41                                                                  // 0x739  (0xB41)
  pset  0xC                                                                        // 0x73A  (0xE4C)
  call  label_331                                                                  // 0x73B  (0x4E5)
  calz  bit_high_at_0x048                                                          // 0x73C  (0x5FD)
  jp    nz,  label_225                                                             // 0x73D  (0x746)
  ld    a,   0x2                                                                   // 0x73E  (0xE02)
  ld    xp,  a                                                                     // 0x73F  (0xE80)
  ld    x,   0xD                                                                   // 0x740  (0xB0D)
  calz  clear_0x07D                                                                // 0x741  (0x512)
  pset  0xC                                                                        // 0x742  (0xE4C)
  call  label_324                                                                  // 0x743  (0x4C8)
  calz  set_f_0x07D                                                                // 0x744  (0x509)
  calz  zero_a_xp                                                                  // 0x745  (0x5EF)

label_225:
  ld    a,   0x2                                                                   // 0x746  (0xE02)
  call  label_230                                                                  // 0x747  (0x456)
  ld    y,   0xA                                                                   // 0x748  (0x80A)

label_226:
  ld    a,   0x2                                                                   // 0x749  (0xE02)
  ld    xp,  a                                                                     // 0x74A  (0xE80)
  ld    x,   0x48                                                                  // 0x74B  (0xB48)
  fan   mx,  0x1                                                                   // 0x74C  (0xDA1)
  jp    z,   label_227                                                             // 0x74D  (0x64F)
  ldpy  a,   a                                                                     // 0x74E  (0xEF0)

label_227:
  ld    a,   0x2                                                                   // 0x74F  (0xE02)
  jp    label_229                                                                  // 0x750  (0x52)

label_228:
  ld    a,   0x6                                                                   // 0x751  (0xE06)

label_229:
  ld    b,   0x5                                                                   // 0x752  (0xE15)
  pset  0x8                                                                        // 0x753  (0xE48)
  call  label_273                                                                  // 0x754  (0x4A9)
  jp    label_221                                                                  // 0x755  (0x12)

label_230:
  set   f,   0x4                                                                   // 0x756  (0xF44)
  ld    x,   0x46                                                                  // 0x757  (0xB46)
  add   mx,  a                                                                     // 0x758  (0xA88)
  ldpx  a,   a                                                                     // 0x759  (0xEE0)
  adc   mx,  0x0                                                                   // 0x75A  (0xC60)
  jp    nc,  label_231                                                             // 0x75B  (0x35E)
  ld    x,   0x46                                                                  // 0x75C  (0xB46)
  lbpx  mx,  0x99                                                                  // 0x75D  (0x999)

label_231:
  rst   f,   0xB                                                                   // 0x75E  (0xF5B)
  pset  0x6                                                                        // 0x75F  (0xE46)
  jp    label_214                                                                  // 0x760  (0xE5)

label_232:
  calz  zero_a_xp                                                                  // 0x761  (0x5EF)
  ld    x,   0x5D                                                                  // 0x762  (0xB5D)
  lbpx  mx,  0x10                                                                  // 0x763  (0x910)
  ld    x,   0x73                                                                  // 0x764  (0xB73)
  ldpx  mx,  0x0                                                                   // 0x765  (0xE60)
  ld    x,   0x40                                                                  // 0x766  (0xB40)
  ldpx  mx,  0x1                                                                   // 0x767  (0xE61)
  ldpx  mx,  0x1                                                                   // 0x768  (0xE61)
  ldpx  mx,  0x0                                                                   // 0x769  (0xE60)
  ldpx  mx,  0x0                                                                   // 0x76A  (0xE60)
  ld    x,   0x46                                                                  // 0x76B  (0xB46)
  lbpx  mx,  0x5                                                                   // 0x76C  (0x905)
  ld    x,   0x54                                                                  // 0x76D  (0xB54)
  lbpx  mx,  0x0                                                                   // 0x76E  (0x900)
  ld    x,   0x48                                                                  // 0x76F  (0xB48)
  ldpx  mx,  0x0                                                                   // 0x770  (0xE60)
  ldpx  mx,  0x0                                                                   // 0x771  (0xE60)
  ldpx  mx,  0x0                                                                   // 0x772  (0xE60)
  ldpx  mx,  0xF                                                                   // 0x773  (0xE6F)
  ldpx  mx,  0x0                                                                   // 0x774  (0xE60)
  ldpx  mx,  0x0                                                                   // 0x775  (0xE60)
  ldpx  mx,  0x0                                                                   // 0x776  (0xE60)
  ldpx  mx,  0x0                                                                   // 0x777  (0xE60)
  ldpx  mx,  0x0                                                                   // 0x778  (0xE60)
  ldpx  mx,  0x0                                                                   // 0x779  (0xE60)
  ld    x,   0x5C                                                                  // 0x77A  (0xB5C)
  ldpx  mx,  0x0                                                                   // 0x77B  (0xE60)
  ld    a,   0x2                                                                   // 0x77C  (0xE02)
  ld    xp,  a                                                                     // 0x77D  (0xE80)
  ld    x,   0x0                                                                   // 0x77E  (0xB00)
  lbpx  mx,  0x0                                                                   // 0x77F  (0x900)
  lbpx  mx,  0x2                                                                   // 0x780  (0x902)
  lbpx  mx,  0xFF                                                                  // 0x781  (0x9FF)
  lbpx  mx,  0xF                                                                   // 0x782  (0x90F)
  ldpx  mx,  0x0                                                                   // 0x783  (0xE60)
  ldpx  mx,  0x0                                                                   // 0x784  (0xE60)
  calz  clear_0x07D                                                                // 0x785  (0x512)
  lbpx  mx,  0x0                                                                   // 0x786  (0x900)
  ldpx  mx,  0x0                                                                   // 0x787  (0xE60)
  calz  set_f_0x07D                                                                // 0x788  (0x509)
  ld    x,   0xF                                                                   // 0x789  (0xB0F)
  ldpx  mx,  0xF                                                                   // 0x78A  (0xE6F)
  ld    x,   0x12                                                                  // 0x78B  (0xB12)
  ldpx  mx,  0xF                                                                   // 0x78C  (0xE6F)
  ld    x,   0x15                                                                  // 0x78D  (0xB15)
  ldpx  mx,  0x5                                                                   // 0x78E  (0xE65)
  ld    x,   0x16                                                                  // 0x78F  (0xB16)
  lbpx  mx,  0x28                                                                  // 0x790  (0x928)
  ret                                                                              // 0x791  (0xFDF)

label_233:
  ld    a,   0x0                                                                   // 0x792  (0xE00)
  ld    yp,  a                                                                     // 0x793  (0xE90)
  calz  one_a_xp                                                                   // 0x794  (0x5F5)
  ld    y,   0x3A                                                                  // 0x795  (0x83A)
  // Set XL to 0x03A
  ld    xl,  my                                                                    // 0x796  (0xE8B)
  ldpy  a,   a                                                                     // 0x797  (0xEF0)
  // Set XH to 0x03B
  ld    xh,  my                                                                    // 0x798  (0xE87)
  // Set Y to 0x090
  ld    y,   0x90                                                                  // 0x799  (0x890)
  call  fetch_and_misc_render                                                      // 0x79A  (0x4A3)
  call  fetch_and_misc_render                                                      // 0x79B  (0x4A3)
  call  fetch_and_misc_render                                                      // 0x79C  (0x4A3)
  call  fetch_and_misc_render                                                      // 0x79D  (0x4A3)
  rst   f,   0xE                                                                   // 0x79E  (0xF5E)
  adc   xh,  0x4                                                                   // 0x79F  (0xA04)
  call  fetch_and_misc_render                                                      // 0x7A0  (0x4A3)
  call  fetch_and_misc_render                                                      // 0x7A1  (0x4A3)
  call  fetch_and_misc_render                                                      // 0x7A2  (0x4A3)
  // One last time through, making 8 total runs
  // Fallthrough

// 
// Fetch Y and Y + 1 and feed that into selecting page and upper nibble of PC for graphics
// Only renders in 0x16-17 blocks
//
fetch_and_misc_render:
  // label_233 above will start at 0x090
  // label_279 below will do one pass at 0x0A8
  ldpy  a,   my                                                                    // 0x7A3  (0xEF3)
  ldpy  b,   my                                                                    // 0x7A4  (0xEF7)


// Falls through from label_234
//
// Renders graphics in the 0x16-17 blocks
// Uses A, B to determine which graphic
// Probably a misc render function for side text and stuff
//
misc_render:
  push  b                                                                          // 0x7A5  (0xFC1)
  ld    b,   0x0                                                                   // 0x7A6  (0xE10)
  rrc   a                                                                          // 0x7A7  (0xE8C)
  rrc   b                                                                          // 0x7A8  (0xE8D)
  ld    m0,  b                                                                     // 0x7A9  (0xF90)
  pop   b                                                                          // 0x7AA  (0xFD1)
  cp    b,   0x4                                                                   // 0x7AB  (0xDD4)
  pset  0x7                                                                        // 0x7AC  (0xE47)
  // If b >= 4, then clear 16 addresses and return
  jp    nc,  clear_16_addrs                                                        // 0x7AD  (0x3B8)
  add   a,   a                                                                     // 0x7AE  (0xA80)
  // Clear carry
  rst   f,   0xE                                                                   // 0x7AF  (0xF5E)
  // b < 4
  // 3 -> 1 + c
  // 2 -> 1
  // 1 -> 0 + c
  // 0 -> 0
  rrc   b                                                                          // 0x7B0  (0xE8D)
  rrc   a                                                                          // 0x7B1  (0xE8C)
  // Clear carry
  add   a,   0x0                                                                   // 0x7B2  (0xC00)
  // 0/1 + 6 = 6/7
  adc   b,   0x6                                                                   // 0x7B3  (0xC56)
  ld    m1,  a                                                                     // 0x7B4  (0xF81)
  ld    m2,  b                                                                     // 0x7B5  (0xF92)
  
  // render page calc: (6 & 7) * 4 = 6 * 4 = 0xC + 0xC = 0x8 + C
  // m2 = 8
  // jpba will be b = 1, a = 8
  // Jump to 0x16 page
  // OR
  // render page calc: (7 & 7) * 4 = 7 * 4 = 0xE + 0xE = 0xC + C
  // m2 = C
  // jpba will be b = 1, a = C
  // Jump to 0x17 page
  pset  0x0                                                                        // 0x7B6  (0xE40)
  jp    render_asset                                                               // 0x7B7  (0x0)

//
// Clear memory at X - X + 15. Returns
//
clear_16_addrs:
  lbpx  mx,  0x0                                                                   // 0x7B8  (0x900)
  lbpx  mx,  0x0                                                                   // 0x7B9  (0x900)
  lbpx  mx,  0x0                                                                   // 0x7BA  (0x900)
  lbpx  mx,  0x0                                                                   // 0x7BB  (0x900)

//
// Clear memory at X - X + 7. Returns
//
clear_8_addrs_ret:
  lbpx  mx,  0x0                                                                   // 0x7BC  (0x900)
  lbpx  mx,  0x0                                                                   // 0x7BD  (0x900)
  lbpx  mx,  0x0                                                                   // 0x7BE  (0x900)
  retd  0x0                                                                        // 0x7BF  (0x100)

label_238:
  calz  zero_b_xp                                                                  // 0x7C0  (0x5F2)
  ld    x,   0x2C                                                                  // 0x7C1  (0xB2C)
  call  label_241                                                                  // 0x7C2  (0x4D5)
  calz  check_0x04A_highbit                                                        // 0x7C3  (0x5B3)
  ld    a,   0x2                                                                   // 0x7C4  (0xE02)
  ld    xp,  a                                                                     // 0x7C5  (0xE80)
  jp    z,   label_239                                                             // 0x7C6  (0x6CB)
  ld    x,   0x5                                                                   // 0x7C7  (0xB05)
  cp    mx,  0x4                                                                   // 0x7C8  (0xDE4)
  jp    c,   label_240                                                             // 0x7C9  (0x2D1)
  jp    label_242                                                                  // 0x7CA  (0xE1)

label_239:
  ld    x,   0x8                                                                   // 0x7CB  (0xB08)
  cp    mx,  0x0                                                                   // 0x7CC  (0xDE0)
  jp    nz,  label_240                                                             // 0x7CD  (0x7D1)
  ld    x,   0x9                                                                   // 0x7CE  (0xB09)
  cp    mx,  0x0                                                                   // 0x7CF  (0xDE0)
  jp    z,   label_242                                                             // 0x7D0  (0x6E1)

label_240:
  calz  zero_a_xp                                                                  // 0x7D1  (0x5EF)
  ld    x,   0x2D                                                                  // 0x7D2  (0xB2D)
  or    mx,  0x8                                                                   // 0x7D3  (0xCE8)
  jp    label_242                                                                  // 0x7D4  (0xE1)

label_241:
  add   a,   0x8                                                                   // 0x7D5  (0xC08)
  adc   b,   0xD                                                                   // 0x7D6  (0xC5D)
  jpba                                                                             // 0x7D7  (0xFE8)
  
// Jump table for label immediately before this
  retd  0x0                                                                        // 0x7D8  (0x100)
  retd  0x1                                                                        // 0x7D9  (0x101)
  retd  0x2                                                                        // 0x7DA  (0x102)
  retd  0x4                                                                        // 0x7DB  (0x104)
  retd  0x8                                                                        // 0x7DC  (0x108)
  retd  0x10                                                                       // 0x7DD  (0x110)
  retd  0x20                                                                       // 0x7DE  (0x120)
  retd  0x40                                                                       // 0x7DF  (0x140)
  retd  0x80                                                                       // 0x7E0  (0x180)

label_242:
  ld    a,   0xE                                                                   // 0x7E1  (0xE0E)
  ld    xp,  a                                                                     // 0x7E2  (0xE80)
  ld    a,   0x0                                                                   // 0x7E3  (0xE00)
  ld    yp,  a                                                                     // 0x7E4  (0xE90)
  ld    y,   0x2C                                                                  // 0x7E5  (0x82C)
  ldpy  a,   my                                                                    // 0x7E6  (0xEF3)
  ld    b,   my                                                                    // 0x7E7  (0xEC7)
  ld    x,   0x10                                                                  // 0x7E8  (0xB10)
  ld    mx,  a                                                                     // 0x7E9  (0xEC8)
  rrc   a                                                                          // 0x7EA  (0xE8C)
  ld    x,   0x22                                                                  // 0x7EB  (0xB22)
  ld    mx,  a                                                                     // 0x7EC  (0xEC8)
  rrc   a                                                                          // 0x7ED  (0xE8C)
  ld    x,   0x24                                                                  // 0x7EE  (0xB24)
  ld    mx,  a                                                                     // 0x7EF  (0xEC8)
  rrc   a                                                                          // 0x7F0  (0xE8C)
  ld    x,   0x26                                                                  // 0x7F1  (0xB26)
  ld    mx,  a                                                                     // 0x7F2  (0xEC8)
  ld    x,   0xB9                                                                  // 0x7F3  (0xBB9)
  ld    mx,  b                                                                     // 0x7F4  (0xEC9)
  rlc   b                                                                          // 0x7F5  (0xAF5)
  ld    x,   0xCB                                                                  // 0x7F6  (0xBCB)
  ld    mx,  b                                                                     // 0x7F7  (0xEC9)
  rlc   b                                                                          // 0x7F8  (0xAF5)
  ld    x,   0xCD                                                                  // 0x7F9  (0xBCD)
  ld    mx,  b                                                                     // 0x7FA  (0xEC9)
  rlc   b                                                                          // 0x7FB  (0xAF5)
  ld    x,   0xCF                                                                  // 0x7FC  (0xBCF)
  ld    mx,  b                                                                     // 0x7FD  (0xEC9)
  ret                                                                              // 0x7FE  (0xFDF)
  nop7                                                                             // 0x7FF  (0xFFF)
  
// Jump table for choose_x_word_244
  retd  0x20                                                                       // 0x800  (0x120)
  retd  0x8                                                                        // 0x801  (0x108)
  retd  0x1                                                                        // 0x802  (0x101)
  retd  0x40                                                                       // 0x803  (0x140)
  retd  0x2                                                                        // 0x804  (0x102)
  retd  0x80                                                                       // 0x805  (0x180)
  retd  0x10                                                                       // 0x806  (0x110)
  retd  0x4                                                                        // 0x807  (0x104)

//
// Load X, X + 1 with a value based on A
// Returns
//
choose_x_word_244:
  fan   a,   0x8                                                                   // 0x808  (0xD88)
  // If high bit not set, jump to {0x0, a}
  jp    z,   jp_a                                                                  // 0x809  (0x60B)
  // If high bit set, load X, X + 1 with 0
  retd  0x0                                                                        // 0x80A  (0x100)

//
// Jumps to {0x0, a} (zeroing b)
// Used only for a set of possible words to load X, X + 1 with
// Returns afterwards
//
jp_a:
  ld    b,   0x0                                                                   // 0x80B  (0xE10)
  jpba                                                                             // 0x80C  (0xFE8)

label_245:
  ld    b,   0x1                                                                   // 0x80D  (0xE11)
  ld    xp,  b                                                                     // 0x80E  (0xE81)

label_246:
  lbpx  mx,  0x0                                                                   // 0x80F  (0x900)
  lbpx  mx,  0x0                                                                   // 0x810  (0x900)
  add   a,   0xF                                                                   // 0x811  (0xC0F)
  jp    nz,  label_246                                                             // 0x812  (0x70F)
  ret                                                                              // 0x813  (0xFDF)

label_247:
  calz  zero_a_xp                                                                  // 0x814  (0x5EF)
  ld    x,   0x80                                                                  // 0x815  (0xB80)
  ld    mx,  0x0                                                                   // 0x816  (0xE20)

label_248:
  call  label_253                                                                  // 0x817  (0x436)
  calz  label_34                                                                   // 0x818  (0x5DE)
  calz  zero_a_xp                                                                  // 0x819  (0x5EF)
  ld    x,   0x81                                                                  // 0x81A  (0xB81)
  cp    mx,  0x0                                                                   // 0x81B  (0xDE0)
  jp    z,   label_249                                                             // 0x81C  (0x61E)
  call  label_258                                                                  // 0x81D  (0x467)

label_249:
  calz  copy_video_buf_to_vram                                                     // 0x81E  (0x556)
  calz  copy_0x026_7_to_8_9                                                        // 0x81F  (0x521)
  ld    x,   0x57                                                                  // 0x820  (0xB57)
  ld    mx,  0xF                                                                   // 0x821  (0xE2F)

label_250:
  calz  copy_0x026_7_to_8_9                                                        // 0x822  (0x521)
  ld    x,   0x57                                                                  // 0x823  (0xB57)
  cp    mx,  0x0                                                                   // 0x824  (0xDE0)
  jp    z,   label_252                                                             // 0x825  (0x633)
  fan   b,   0x1                                                                   // 0x826  (0xD91)
  jp    nz,  label_252                                                             // 0x827  (0x733)
  fan   b,   0x6                                                                   // 0x828  (0xD96)
  jp    z,   label_250                                                             // 0x829  (0x622)
  calz  label_25                                                                   // 0x82A  (0x5BB)
  ld    x,   0x80                                                                  // 0x82B  (0xB80)
  add   mx,  0x1                                                                   // 0x82C  (0xC21)
  cp    mx,  0x4                                                                   // 0x82D  (0xDE4)
  jp    c,   label_251                                                             // 0x82E  (0x230)
  ld    mx,  0x0                                                                   // 0x82F  (0xE20)

label_251:
  pset  0xF                                                                        // 0x830  (0xE4F)
  call  label_357                                                                  // 0x831  (0x400)
  jp    z,   label_248                                                             // 0x832  (0x617)

label_252:
  calz  label_25                                                                   // 0x833  (0x5BB)
  pset  0x5                                                                        // 0x834  (0xE45)
  jp    label_160                                                                  // 0x835  (0x1A)

label_253:
  calz  zero_b_xp                                                                  // 0x836  (0x5F2)
  ld    yp,  b                                                                     // 0x837  (0xE91)
  ld    x,   0x80                                                                  // 0x838  (0xB80)
  ldpx  a,   mx                                                                    // 0x839  (0xEE2)
  ldpx  mx,  0x0                                                                   // 0x83A  (0xE60)
  add   a,   0xF                                                                   // 0x83B  (0xC0F)
  adc   b,   0x3                                                                   // 0x83C  (0xC53)
  ld    x,   0x90                                                                  // 0x83D  (0xB90)
  jpba                                                                             // 0x83E  (0xFE8)
  jp    label_254                                                                  // 0x83F  (0x43)
  jp    label_257                                                                  // 0x840  (0x5C)
  jp    label_264                                                                  // 0x841  (0x83)
  jp    label_265                                                                  // 0x842  (0x89)

label_254:
  lbpx  mx,  0x18                                                                  // 0x843  (0x918)
  ld    y,   0x55                                                                  // 0x844  (0x855)
  ldpx  mx,  my                                                                    // 0x845  (0xEEB)
  ld    b,   0x0                                                                   // 0x846  (0xE10)
  cp    my,  0x0                                                                   // 0x847  (0xDF0)
  jp    nz,  label_255                                                             // 0x848  (0x74A)
  ld    b,   0xF                                                                   // 0x849  (0xE1F)

label_255:
  ldpx  mx,  b                                                                     // 0x84A  (0xEE9)
  ld    y,   0x54                                                                  // 0x84B  (0x854)
  ldpx  mx,  my                                                                    // 0x84C  (0xEEB)
  ldpx  mx,  0x0                                                                   // 0x84D  (0xE60)
  lbpx  mx,  0x19                                                                  // 0x84E  (0x919)
  lbpx  mx,  0x1A                                                                  // 0x84F  (0x91A)
  ld    y,   0x47                                                                  // 0x850  (0x847)
  ldpx  mx,  my                                                                    // 0x851  (0xEEB)
  ld    b,   0x0                                                                   // 0x852  (0xE10)
  cp    my,  0x0                                                                   // 0x853  (0xDF0)
  jp    nz,  label_256                                                             // 0x854  (0x756)
  ld    b,   0xF                                                                   // 0x855  (0xE1F)

label_256:
  ldpx  mx,  b                                                                     // 0x856  (0xEE9)
  ld    y,   0x46                                                                  // 0x857  (0x846)
  ldpx  mx,  my                                                                    // 0x858  (0xEEB)
  ldpx  mx,  0x0                                                                   // 0x859  (0xE60)
  lbpx  mx,  0x1B                                                                  // 0x85A  (0x91B)
  ret                                                                              // 0x85B  (0xFDF)

label_257:
  lbpx  mx,  0x34                                                                  // 0x85C  (0x934)
  lbpx  mx,  0x35                                                                  // 0x85D  (0x935)
  lbpx  mx,  0x36                                                                  // 0x85E  (0x936)
  lbpx  mx,  0x37                                                                  // 0x85F  (0x937)
  lbpx  mx,  0xFF                                                                  // 0x860  (0x9FF)
  lbpx  mx,  0xFF                                                                  // 0x861  (0x9FF)
  lbpx  mx,  0xFF                                                                  // 0x862  (0x9FF)
  lbpx  mx,  0xFF                                                                  // 0x863  (0x9FF)
  ld    y,   0x81                                                                  // 0x864  (0x881)
  ld    my,  0x1                                                                   // 0x865  (0xE31)
  ret                                                                              // 0x866  (0xFDF)

label_258:
  calz  one_a_xp                                                                   // 0x867  (0x5F5)
  ld    x,   0xC2                                                                  // 0x868  (0xBC2)
  lbpx  mx,  0x3D                                                                  // 0x869  (0x93D)
  call  label_261                                                                  // 0x86A  (0x47D)
  lbpx  mx,  0x43                                                                  // 0x86B  (0x943)
  call  label_261                                                                  // 0x86C  (0x47D)
  lbpx  mx,  0x3D                                                                  // 0x86D  (0x93D)
  ld    a,   0x0                                                                   // 0x86E  (0xE00)
  ld    yp,  a                                                                     // 0x86F  (0xE90)
  ld    y,   0x43                                                                  // 0x870  (0x843)
  ld    a,   my                                                                    // 0x871  (0xEC3)
  cp    a,   0x0                                                                   // 0x872  (0xDC0)
  jp    nz,  label_259                                                             // 0x873  (0x775)
  ld    a,   0x1                                                                   // 0x874  (0xE01)

label_259:
  ld    m0,  a                                                                     // 0x875  (0xF80)
  ld    x,   0xC6                                                                  // 0x876  (0xBC6)

label_260:
  dec   m0                                                                         // 0x877  (0xF70)
  jp    z,   label_263                                                             // 0x878  (0x682)
  lbpx  mx,  0x5A                                                                  // 0x879  (0x95A)
  ldpx  a,   a                                                                     // 0x87A  (0xEE0)
  ldpx  a,   a                                                                     // 0x87B  (0xEE0)
  jp    label_260                                                                  // 0x87C  (0x77)

label_261:
  ld    a,   0xE                                                                   // 0x87D  (0xE0E)
  ld    m0,  a                                                                     // 0x87E  (0xF80)

label_262:
  lbpx  mx,  0x42                                                                  // 0x87F  (0x942)
  dec   m0                                                                         // 0x880  (0xF70)
  jp    nz,  label_262                                                             // 0x881  (0x77F)

label_263:
  ret                                                                              // 0x882  (0xFDF)

label_264:
  lbpx  mx,  0x2E                                                                  // 0x883  (0x92E)
  lbpx  mx,  0x2F                                                                  // 0x884  (0x92F)
  lbpx  mx,  0x30                                                                  // 0x885  (0x930)
  lbpx  mx,  0xFF                                                                  // 0x886  (0x9FF)
  ld    y,   0x40                                                                  // 0x887  (0x840)
  jp    label_266                                                                  // 0x888  (0x8C)

label_265:
  pset  0xB                                                                        // 0x889  (0xE4B)
  call  label_310                                                                  // 0x88A  (0x4F8)
  ld    y,   0x41                                                                  // 0x88B  (0x841)

label_266:
  ld    a,   0x4                                                                   // 0x88C  (0xE04)
  cp    my,  0xF                                                                   // 0x88D  (0xDFF)
  jp    nc,  label_267                                                             // 0x88E  (0x394)
  ld    a,   my                                                                    // 0x88F  (0xEC3)
  add   a,   0x1                                                                   // 0x890  (0xC01)
  rrc   a                                                                          // 0x891  (0xE8C)
  rrc   a                                                                          // 0x892  (0xE8C)
  and   a,   0x3                                                                   // 0x893  (0xC83)

label_267:
  ld    b,   0x4                                                                   // 0x894  (0xE14)

label_268:
  cp    a,   0x0                                                                   // 0x895  (0xDC0)
  jp    nz,  label_269                                                             // 0x896  (0x799)
  lbpx  mx,  0x1D                                                                  // 0x897  (0x91D)
  jp    label_270                                                                  // 0x898  (0x9B)

label_269:
  add   a,   0xF                                                                   // 0x899  (0xC0F)
  lbpx  mx,  0x1C                                                                  // 0x89A  (0x91C)

label_270:
  add   b,   0xF                                                                   // 0x89B  (0xC1F)
  jp    nz,  label_268                                                             // 0x89C  (0x795)
  ret                                                                              // 0x89D  (0xFDF)

label_271:
  ld    y,   0x0                                                                   // 0x89E  (0x800)
  push  b                                                                          // 0x89F  (0xFC1)
  push  yh                                                                         // 0x8A0  (0xFC8)
  push  yl                                                                         // 0x8A1  (0xFC9)
  pset  0x5                                                                        // 0x8A2  (0xE45)
  call  label_176                                                                  // 0x8A3  (0x496)
  pop   yl                                                                         // 0x8A4  (0xFD9)
  pop   yh                                                                         // 0x8A5  (0xFD8)
  calz  zero_a_xp                                                                  // 0x8A6  (0x5EF)
  jp    label_274                                                                  // 0x8A7  (0xAD)

label_272:
  ld    y,   0x0                                                                   // 0x8A8  (0x800)

label_273:
  push  b                                                                          // 0x8A9  (0xFC1)
  calz  zero_b_xp                                                                  // 0x8AA  (0x5F2)
  ld    x,   0x5E                                                                  // 0x8AB  (0xB5E)
  ldpx  mx,  a                                                                     // 0x8AC  (0xEE8)

label_274:
  ld    x,   0x57                                                                  // 0x8AD  (0xB57)
  pop   mx                                                                         // 0x8AE  (0xFD2)
  ld    a,   yl                                                                    // 0x8AF  (0xEB8)
  ld    b,   yh                                                                    // 0x8B0  (0xEB5)
  ld    x,   0xA6                                                                  // 0x8B1  (0xBA6)
  pset  0xE                                                                        // 0x8B2  (0xE4E)
  call  jp_table_0xE00                                                             // 0x8B3  (0x40D)
  ld    x,   0xAA                                                                  // 0x8B4  (0xBAA)
  ldpx  mx,  0x0                                                                   // 0x8B5  (0xE60)
  pset  0x4                                                                        // 0x8B6  (0xE44)
  call  label_142                                                                  // 0x8B7  (0x465)
  calz  copy_0x026_7_to_8_9                                                        // 0x8B8  (0x521)

label_275:
  calz  clear_page_0x100                                                           // 0x8B9  (0x540)
  pset  0x4                                                                        // 0x8BA  (0xE44)
  call  label_145                                                                  // 0x8BB  (0x486)
  calz  zero_a_xp                                                                  // 0x8BC  (0x5EF)
  ld    yp,  a                                                                     // 0x8BD  (0xE90)
  ld    x,   0xAA                                                                  // 0x8BE  (0xBAA)
  add   mx,  0xF                                                                   // 0x8BF  (0xC2F)
  jp    c,   label_276                                                             // 0x8C0  (0x2D5)
  ld    x,   0xA6                                                                  // 0x8C1  (0xBA6)
  ld    a,   mx                                                                    // 0x8C2  (0xEC2)
  add   mx,  0x2                                                                   // 0x8C3  (0xC22)
  ldpx  a,   a                                                                     // 0x8C4  (0xEE0)
  ld    b,   mx                                                                    // 0x8C5  (0xEC6)
  adc   mx,  0x0                                                                   // 0x8C6  (0xC60)
  ld    x,   0xA2                                                                  // 0x8C7  (0xBA2)
  pset  0xE                                                                        // 0x8C8  (0xE4E)
  call  jp_table_0xE00                                                             // 0x8C9  (0x40D)
  ld    x,   0xA2                                                                  // 0x8CA  (0xBA2)
  ld    y,   0xA8                                                                  // 0x8CB  (0x8A8)
  ldpx  my,  mx                                                                    // 0x8CC  (0xEEE)
  ldpy  a,   a                                                                     // 0x8CD  (0xEF0)
  ld    my,  mx                                                                    // 0x8CE  (0xECE)
  and   my,  0x3                                                                   // 0x8CF  (0xCB3)
  ld    y,   0xAA                                                                  // 0x8D0  (0x8AA)
  ld    my,  mx                                                                    // 0x8D1  (0xECE)
  rrc   my                                                                         // 0x8D2  (0xE8F)
  rrc   my                                                                         // 0x8D3  (0xE8F)
  and   my,  0x3                                                                   // 0x8D4  (0xCB3)

label_276:
  ld    x,   0xA8                                                                  // 0x8D5  (0xBA8)
  cp    mx,  0xF                                                                   // 0x8D6  (0xDEF)
  jp    nz,  label_277                                                             // 0x8D7  (0x7DB)
  ldpx  a,   a                                                                     // 0x8D8  (0xEE0)
  cp    mx,  0x3                                                                   // 0x8D9  (0xDE3)
  jp    z,   label_280                                                             // 0x8DA  (0x6F4)

label_277:
  ld    y,   0xA4                                                                  // 0x8DB  (0x8A4)
  ld    xl,  my                                                                    // 0x8DC  (0xE8B)
  ldpy  a,   a                                                                     // 0x8DD  (0xEF0)
  ld    xh,  my                                                                    // 0x8DE  (0xE87)
  ld    y,   0x5D                                                                  // 0x8DF  (0x85D)
  cp    my,  0x1                                                                   // 0x8E0  (0xDF1)
  jp    nz,  label_279                                                             // 0x8E1  (0x7F0)
  ld    a,   xh                                                                    // 0x8E2  (0xEA4)
  cp    a,   0x0                                                                   // 0x8E3  (0xDC0)
  jp    z,   label_278                                                             // 0x8E4  (0x6E6)
  or    a,   0x8                                                                   // 0x8E5  (0xCC8)

label_278:
  ld    xh,  a                                                                     // 0x8E6  (0xE84)
  rst   f,   0xE                                                                   // 0x8E7  (0xF5E)
  adc   xl,  0x8                                                                   // 0x8E8  (0xA18)
  adc   xh,  0xF                                                                   // 0x8E9  (0xA0F)
  ld    a,   xh                                                                    // 0x8EA  (0xEA4)
  or    a,   0x8                                                                   // 0x8EB  (0xCC8)
  cp    a,   0xF                                                                   // 0x8EC  (0xDCF)
  jp    nz,  label_279                                                             // 0x8ED  (0x7F0)
  rst   f,   0xE                                                                   // 0x8EE  (0xF5E)
  adc   xh,  0x1                                                                   // 0x8EF  (0xA01)

label_279:
  calz  one_a_xp                                                                   // 0x8F0  (0x5F5)
  ld    y,   0xA8                                                                  // 0x8F1  (0x8A8)
  pset  0x7                                                                        // 0x8F2  (0xE47)
  call  fetch_and_misc_render                                                      // 0x8F3  (0x4A3)

label_280:
  calz  calz_copy_buf_and_render_misc                                              // 0x8F4  (0x554)
  calz  copy_0x026_7_to_8_9                                                        // 0x8F5  (0x521)
  ld    x,   0x57                                                                  // 0x8F6  (0xB57)
  cp    mx,  0x0                                                                   // 0x8F7  (0xDE0)
  jp    z,   ret_280                                                               // 0x8F8  (0x6FF)
  ld    x,   0x74                                                                  // 0x8F9  (0xB74)
  cp    mx,  0x0                                                                   // 0x8FA  (0xDE0)
  jp    z,   label_275                                                             // 0x8FB  (0x6B9)
  fan   b,   0x7                                                                   // 0x8FC  (0xD97)
  jp    z,   label_275                                                             // 0x8FD  (0x6B9)
  calz  label_25                                                                   // 0x8FE  (0x5BB)

ret_280:
  ret                                                                              // 0x8FF  (0xFDF)

label_282:
  cp    a,   0x0                                                                   // 0x900  (0xDC0)
  jp    z,   label_283                                                             // 0x901  (0x605)
  ld    x,   0x5A                                                                  // 0x902  (0xB5A)
  set   f,   0x1                                                                   // 0x903  (0xF41)
  adc   mx,  a                                                                     // 0x904  (0xA98)

label_283:
  ret                                                                              // 0x905  (0xFDF)

//
// 8 times, copy video buffer data to VRAM
// Clears 0x100 page afterwards (where the video cache is)
// Leaves m2 = 8, m3 = 0
// TODO: I don't really understand this
// Returns
copy_video_buf_8x:
  ld    a,   0x0                                                                   // 0x906  (0xE00)
  ld    m2,  a                                                                     // 0x907  (0xF82)
  ld    a,   0x8                                                                   // 0x908  (0xE08)
  ld    m3,  a                                                                     // 0x909  (0xF83)

loop_284:
  call  or_0x100_ab                                                                // 0x90A  (0x413)
  calz  copy_video_buf_to_vram                                                     // 0x90B  (0x556)
  ld    x,   0x1                                                                   // 0x90C  (0xB01)
  calz  copy_xhl_to_0x022_or_loop_0x023                                            // 0x90D  (0x53C)
  inc   m2                                                                         // 0x90E  (0xF62)
  dec   m3                                                                         // 0x90F  (0xF73)
  jp    nz,  loop_284                                                              // 0x910  (0x70A)
  calz  clear_page_0x100                                                           // 0x911  (0x540)
  ret                                                                              // 0x912  (0xFDF)

//
// Set M0, M1 from a set of 9 values
// ORs the 0x100 section of memory with the values
or_0x100_ab:
  calz  zero_a_xp                                                                  // 0x913  (0x5EF)
  ld    x,   0x0                                                                   // 0x914  (0xB00)
  ld    a,   m2                                                                    // 0x915  (0xFA2)
  pset  0x8                                                                        // 0x916  (0xE48)
  // Based on the current value of A/M2, load 0x000 with different data
  // This is M0, M1, which determines the graphic displayed
  call  choose_x_word_244                                                          // 0x917  (0x408)
  calz  one_a_xp                                                                   // 0x918  (0x5F5)
  // X is 0x100
  ld    x,   0x0                                                                   // 0x919  (0xB00)
  // These are the values loaded by choose_x_word_244
  ld    a,   m0                                                                    // 0x91A  (0xFA0)
  ld    b,   m1                                                                    // 0x91B  (0xFB1)
  // Clear carry
  rst   f,   0xE                                                                   // 0x91C  (0xF5E)

// Fallthrough from label_286
loop_or_0x1XX_ab:
  // Numbers are for the first pass through the loop
  // 0x100 |= a
  or    mx,  a                                                                     // 0x91D  (0xAD8)
  ldpx  a,   a                                                                     // 0x91E  (0xEE0)
  // 0x101 |= a
  or    mx,  a                                                                     // 0x91F  (0xAD8)
  ldpx  a,   a                                                                     // 0x920  (0xEE0)
  // 0x102 |= b
  or    mx,  b                                                                     // 0x921  (0xAD9)
  ldpx  a,   a                                                                     // 0x922  (0xEE0)
  // 0x103 |= b
  or    mx,  b                                                                     // 0x923  (0xAD9)
  adc   xl,  0x1                                                                   // 0x924  (0xA11)
  // X is 0x104
  // If xl addition overflows, xh gets the next carry
  adc   xh,  0x0                                                                   // 0x925  (0xA00)
  // Continue until xh overflows
  jp    nc,  loop_or_0x1XX_ab                                                      // 0x926  (0x31D)
  ret                                                                              // 0x927  (0xFDF)

label_288:
  ld    m0,  a                                                                     // 0x928  (0xF80)
  ld    m3,  b                                                                     // 0x929  (0xF93)
  ld    x,   0x5D                                                                  // 0x92A  (0xB5D)
  ld    a,   mx                                                                    // 0x92B  (0xEC2)
  ld    b,   0x0                                                                   // 0x92C  (0xE10)
  ld    x,   0x1                                                                   // 0x92D  (0xB01)
  pset  0xC                                                                        // 0x92E  (0xE4C)
  call  jp_table_0xC00                                                             // 0x92F  (0x479)
  ld    a,   m1                                                                    // 0x930  (0xFA1)
  ld    b,   m0                                                                    // 0x931  (0xFB0)
  add   a,   b                                                                     // 0x932  (0xA81)
  ld    b,   m2                                                                    // 0x933  (0xFB2)
  adc   b,   0x0                                                                   // 0x934  (0xC50)
  ld    x,   0x24                                                                  // 0x935  (0xB24)
  pset  0xC                                                                        // 0x936  (0xE4C)
  call  jp_table_0xC00                                                             // 0x937  (0x479)
  jp    label_290                                                                  // 0x938  (0x49)

//
// Set m0, m3
label_289:
  ld    m0,  a                                                                     // 0x939  (0xF80)
  ld    m3,  b                                                                     // 0x93A  (0xF93)
  ld    x,   0x5D                                                                  // 0x93B  (0xB5D)
  ld    a,   mx                                                                    // 0x93C  (0xEC2)
  ld    b,   0x0                                                                   // 0x93D  (0xE10)
  ld    x,   0x1                                                                   // 0x93E  (0xB01)
  pset  0xD                                                                        // 0x93F  (0xE4D)
  call  jp_table_0xD00                                                             // 0x940  (0x47D)
  ld    a,   m1                                                                    // 0x941  (0xFA1)
  ld    b,   m0                                                                    // 0x942  (0xFB0)
  add   a,   b                                                                     // 0x943  (0xA81)
  ld    b,   m2                                                                    // 0x944  (0xFB2)
  adc   b,   0x0                                                                   // 0x945  (0xC50)
  ld    x,   0x24                                                                  // 0x946  (0xB24)
  pset  0xD                                                                        // 0x947  (0xE4D)
  call  jp_table_0xD00                                                             // 0x948  (0x47D)

label_290:
  ld    a,   m3                                                                    // 0x949  (0xFA3)
  and   a,   0x8                                                                   // 0x94A  (0xC88)
  ld    x,   0x25                                                                  // 0x94B  (0xB25)
  xor   mx,  a                                                                     // 0x94C  (0xAE8)
  pset  0x9                                                                        // 0x94D  (0xE49)
  jp    label_291                                                                  // 0x94E  (0x4F)

label_291:
  calz  zero_a_xp                                                                  // 0x94F  (0x5EF)
  ld    m0,  a                                                                     // 0x950  (0xF80)
  ld    x,   0x24                                                                  // 0x951  (0xB24)
  ldpx  a,   mx                                                                    // 0x952  (0xEE2)
  ldpx  b,   mx                                                                    // 0x953  (0xEE6)
  and   b,   0x7                                                                   // 0x954  (0xC97)
  add   a,   0x3                                                                   // 0x955  (0xC03)
  adc   b,   0x0                                                                   // 0x956  (0xC50)
  cp    b,   0x8                                                                   // 0x957  (0xDD8)
  jp    nc,  ret_291                                                               // 0x958  (0x37E)
  ld    m2,  b                                                                     // 0x959  (0xF92)
  ld    m1,  a                                                                     // 0x95A  (0xF81)
  ld    x,   0x3A                                                                  // 0x95B  (0xB3A)
  ldpx  a,   mx                                                                    // 0x95C  (0xEE2)
  ldpx  b,   mx                                                                    // 0x95D  (0xEE6)
  ld    xl,  a                                                                     // 0x95E  (0xE88)
  ld    xh,  b                                                                     // 0x95F  (0xE85)
  calz  one_a_xp                                                                   // 0x960  (0x5F5)
  calz  render_asset                                                               // 0x961  (0x500)
  calz  zero_a_xp                                                                  // 0x962  (0x5EF)
  ld    x,   0x25                                                                  // 0x963  (0xB25)
  fan   mx,  0x8                                                                   // 0x964  (0xDA8)
  jp    z,   ret_291                                                               // 0x965  (0x67E)
  ld    x,   0x3A                                                                  // 0x966  (0xB3A)
  ldpx  a,   mx                                                                    // 0x967  (0xEE2)
  ldpx  b,   mx                                                                    // 0x968  (0xEE6)
  ld    xl,  a                                                                     // 0x969  (0xE88)
  ld    xh,  b                                                                     // 0x96A  (0xE85)
  add   a,   0xE                                                                   // 0x96B  (0xC0E)
  ld    yl,  a                                                                     // 0x96C  (0xE98)
  adc   b,   0x1                                                                   // 0x96D  (0xC51)
  ld    yh,  b                                                                     // 0x96E  (0xE95)
  calz  one_a_xp                                                                   // 0x96F  (0x5F5)
  ld    yp,  a                                                                     // 0x970  (0xE90)
  ld    a,   0x8                                                                   // 0x971  (0xE08)
  ld    m0,  a                                                                     // 0x972  (0xF80)

label_292:
  ld    a,   mx                                                                    // 0x973  (0xEC2)
  ldpx  mx,  my                                                                    // 0x974  (0xEEB)
  ldpy  my,  a                                                                     // 0x975  (0xEFC)
  ld    a,   mx                                                                    // 0x976  (0xEC2)
  ldpx  mx,  my                                                                    // 0x977  (0xEEB)
  ld    my,  a                                                                     // 0x978  (0xECC)
  rst   f,   0xE                                                                   // 0x979  (0xF5E)
  adc   yl,  0xD                                                                   // 0x97A  (0xA3D)
  adc   yh,  0xF                                                                   // 0x97B  (0xA2F)
  dec   m0                                                                         // 0x97C  (0xF70)
  jp    nz,  label_292                                                             // 0x97D  (0x773)

ret_291:
  ret                                                                              // 0x97E  (0xFDF)

label_294:
  pset  0x7                                                                        // 0x97F  (0xE47)
  call  label_232                                                                  // 0x980  (0x461)
  pset  0x4                                                                        // 0x981  (0xE44)
  call  label_142                                                                  // 0x982  (0x465)
  calz  label_38                                                                   // 0x983  (0x5EC)

label_295:
  calz  clear_page_0x100                                                           // 0x984  (0x540)
  calz  label_13                                                                   // 0x985  (0x552)
  calz  copy_0x026_7_to_8_9                                                        // 0x986  (0x521)
  fan   mx,  0x2                                                                   // 0x987  (0xDA2)
  jp    z,   label_295                                                             // 0x988  (0x684)
  pset  0x5                                                                        // 0x989  (0xE45)
  jp    label_167                                                                  // 0x98A  (0x53)
  
// Table for jp_table_0x980
  retd  0x9B                                                                       // 0x98B  (0x19B)
  retd  0x9E                                                                       // 0x98C  (0x19E)
  retd  0xB1                                                                       // 0x98D  (0x1B1)
  retd  0xBE                                                                       // 0x98E  (0x1BE)
  retd  0xC3                                                                       // 0x98F  (0x1C3)
  retd  0xCE                                                                       // 0x990  (0x1CE)
  retd  0xD3                                                                       // 0x991  (0x1D3)
  retd  0xDC                                                                       // 0x992  (0x1DC)
  retd  0xE5                                                                       // 0x993  (0x1E5)
  retd  0xEC                                                                       // 0x994  (0x1EC)
  retd  0xF1                                                                       // 0x995  (0x1F1)
  retd  0x0                                                                        // 0x996  (0x100)
  retd  0x0                                                                        // 0x997  (0x100)
  retd  0x0                                                                        // 0x998  (0x100)
  retd  0x0                                                                        // 0x999  (0x100)
  retd  0x0                                                                        // 0x99A  (0x100)

  lbpx  mx,  0xCF                                                                  // 0x99B  (0x9CF)
  lbpx  mx,  0x10                                                                  // 0x99C  (0x910)
  retd  0x9B                                                                       // 0x99D  (0x19B)
  lbpx  mx,  0xC0                                                                  // 0x99E  (0x9C0)
  retd  0x12                                                                       // 0x99F  (0x112)
  lbpx  mx,  0xC0                                                                  // 0x9A0  (0x9C0)
  retd  0x12                                                                       // 0x9A1  (0x112)
  lbpx  mx,  0xC0                                                                  // 0x9A2  (0x9C0)
  retd  0x14                                                                       // 0x9A3  (0x114)
  lbpx  mx,  0xC0                                                                  // 0x9A4  (0x9C0)
  retd  0x12                                                                       // 0x9A5  (0x112)
  lbpx  mx,  0xC0                                                                  // 0x9A6  (0x9C0)
  retd  0x12                                                                       // 0x9A7  (0x112)
  lbpx  mx,  0xC0                                                                  // 0x9A8  (0x9C0)
  retd  0x12                                                                       // 0x9A9  (0x112)
  lbpx  mx,  0xC0                                                                  // 0x9AA  (0x9C0)
  retd  0x14                                                                       // 0x9AB  (0x114)
  lbpx  mx,  0xC0                                                                  // 0x9AC  (0x9C0)
  retd  0x12                                                                       // 0x9AD  (0x112)
  lbpx  mx,  0xC7                                                                  // 0x9AE  (0x9C7)
  lbpx  mx,  0x8                                                                   // 0x9AF  (0x908)
  retd  0xAE                                                                       // 0x9B0  (0x1AE)
  lbpx  mx,  0xC0                                                                  // 0x9B1  (0x9C0)
  retd  0x10                                                                       // 0x9B2  (0x110)
  lbpx  mx,  0xC1                                                                  // 0x9B3  (0x9C1)
  retd  0xFB                                                                       // 0x9B4  (0x1FB)
  lbpx  mx,  0xF0                                                                  // 0x9B5  (0x9F0)
  retd  0xC                                                                        // 0x9B6  (0x10C)
  lbpx  mx,  0xC0                                                                  // 0x9B7  (0x9C0)
  retd  0x8                                                                        // 0x9B8  (0x108)
  lbpx  mx,  0xF2                                                                  // 0x9B9  (0x9F2)
  retd  0x7                                                                        // 0x9BA  (0x107)
  lbpx  mx,  0xC0                                                                  // 0x9BB  (0x9C0)
  lbpx  mx,  0x14                                                                  // 0x9BC  (0x914)
  retd  0xB1                                                                       // 0x9BD  (0x1B1)
  lbpx  mx,  0xC5                                                                  // 0x9BE  (0x9C5)
  retd  0x10                                                                       // 0x9BF  (0x110)
  lbpx  mx,  0xC1                                                                  // 0x9C0  (0x9C1)
  lbpx  mx,  0xE                                                                   // 0x9C1  (0x90E)
  retd  0xBE                                                                       // 0x9C2  (0x1BE)
  lbpx  mx,  0xC0                                                                  // 0x9C3  (0x9C0)
  retd  0x10                                                                       // 0x9C4  (0x110)
  lbpx  mx,  0xC2                                                                  // 0x9C5  (0x9C2)
  retd  0xFD                                                                       // 0x9C6  (0x1FD)
  lbpx  mx,  0xF3                                                                  // 0x9C7  (0x9F3)
  retd  0x5                                                                        // 0x9C8  (0x105)
  lbpx  mx,  0xC1                                                                  // 0x9C9  (0x9C1)
  retd  0xFD                                                                       // 0x9CA  (0x1FD)
  lbpx  mx,  0xF3                                                                  // 0x9CB  (0x9F3)
  lbpx  mx,  0x3                                                                   // 0x9CC  (0x903)
  retd  0xC3                                                                       // 0x9CD  (0x1C3)
  lbpx  mx,  0xC5                                                                  // 0x9CE  (0x9C5)
  retd  0x10                                                                       // 0x9CF  (0x110)
  lbpx  mx,  0xD0                                                                  // 0x9D0  (0x9D0)
  lbpx  mx,  0x10                                                                  // 0x9D1  (0x910)
  retd  0xCE                                                                       // 0x9D2  (0x1CE)
  lbpx  mx,  0xC0                                                                  // 0x9D3  (0x9C0)
  retd  0x10                                                                       // 0x9D4  (0x110)
  lbpx  mx,  0xC3                                                                  // 0x9D5  (0x9C3)
  retd  0xFF                                                                       // 0x9D6  (0x1FF)
  lbpx  mx,  0xF7                                                                  // 0x9D7  (0x9F7)
  retd  0x3                                                                        // 0x9D8  (0x103)
  lbpx  mx,  0xC2                                                                  // 0x9D9  (0x9C2)
  lbpx  mx,  0xFF                                                                  // 0x9DA  (0x9FF)
  retd  0xD3                                                                       // 0x9DB  (0x1D3)
  lbpx  mx,  0xC0                                                                  // 0x9DC  (0x9C0)
  retd  0x10                                                                       // 0x9DD  (0x110)
  lbpx  mx,  0xC2                                                                  // 0x9DE  (0x9C2)
  retd  0xFD                                                                       // 0x9DF  (0x1FD)
  lbpx  mx,  0xF5                                                                  // 0x9E0  (0x9F5)
  retd  0x5                                                                        // 0x9E1  (0x105)
  lbpx  mx,  0xC1                                                                  // 0x9E2  (0x9C1)
  lbpx  mx,  0xFD                                                                  // 0x9E3  (0x9FD)
  retd  0xDC                                                                       // 0x9E4  (0x1DC)
  lbpx  mx,  0xC7                                                                  // 0x9E5  (0x9C7)
  retd  0x10                                                                       // 0x9E6  (0x110)
  lbpx  mx,  0xD3                                                                  // 0x9E7  (0x9D3)
  retd  0x10                                                                       // 0x9E8  (0x110)
  lbpx  mx,  0xCB                                                                  // 0x9E9  (0x9CB)
  lbpx  mx,  0x10                                                                  // 0x9EA  (0x910)
  retd  0xE5                                                                       // 0x9EB  (0x1E5)
  lbpx  mx,  0xC7                                                                  // 0x9EC  (0x9C7)
  retd  0x10                                                                       // 0x9ED  (0x110)
  lbpx  mx,  0xF7                                                                  // 0x9EE  (0x9F7)
  lbpx  mx,  0x10                                                                  // 0x9EF  (0x910)
  retd  0xEC                                                                       // 0x9F0  (0x1EC)
  lbpx  mx,  0xC0                                                                  // 0x9F1  (0x9C0)
  retd  0x10                                                                       // 0x9F2  (0x110)
  lbpx  mx,  0xC1                                                                  // 0x9F3  (0x9C1)
  retd  0x12                                                                       // 0x9F4  (0x112)
  lbpx  mx,  0xC0                                                                  // 0x9F5  (0x9C0)
  retd  0x10                                                                       // 0x9F6  (0x110)
  lbpx  mx,  0xC0                                                                  // 0x9F7  (0x9C0)
  retd  0x12                                                                       // 0x9F8  (0x112)
  lbpx  mx,  0xC0                                                                  // 0x9F9  (0x9C0)
  retd  0x10                                                                       // 0x9FA  (0x110)
  lbpx  mx,  0xC1                                                                  // 0x9FB  (0x9C1)
  retd  0x12                                                                       // 0x9FC  (0x112)
  lbpx  mx,  0xC7                                                                  // 0x9FD  (0x9C7)
  lbpx  mx,  0x10                                                                  // 0x9FE  (0x910)
  retd  0xFD                                                                       // 0x9FF  (0x1FD)
  
// Jump table for jp_table_0xA00
  retd  0x0                                                                        // 0xA00  (0x100)
  retd  0x10                                                                       // 0xA01  (0x110)
  retd  0x21                                                                       // 0xA02  (0x121)
  retd  0x33                                                                       // 0xA03  (0x133)
  retd  0x44                                                                       // 0xA04  (0x144)
  retd  0x0                                                                        // 0xA05  (0x100)
  retd  0x0                                                                        // 0xA06  (0x100)
  retd  0x0                                                                        // 0xA07  (0x100)
  retd  0x0                                                                        // 0xA08  (0x100)
  retd  0x0                                                                        // 0xA09  (0x100)
  retd  0x0                                                                        // 0xA0A  (0x100)
  retd  0x0                                                                        // 0xA0B  (0x100)
  retd  0x0                                                                        // 0xA0C  (0x100)
  retd  0x0                                                                        // 0xA0D  (0x100)
  retd  0x0                                                                        // 0xA0E  (0x100)
  retd  0x0                                                                        // 0xA0F  (0x100)
  retd  0x0                                                                        // 0xA10  (0x100)
  retd  0x15                                                                       // 0xA11  (0x115)
  retd  0x12                                                                       // 0xA12  (0x112)
  retd  0x33                                                                       // 0xA13  (0x133)
  retd  0x43                                                                       // 0xA14  (0x143)
  retd  0x45                                                                       // 0xA15  (0x145)
  retd  0x0                                                                        // 0xA16  (0x100)
  retd  0x41                                                                       // 0xA17  (0x141)
  retd  0x61                                                                       // 0xA18  (0x161)
  retd  0x13                                                                       // 0xA19  (0x113)
  retd  0x33                                                                       // 0xA1A  (0x133)
  retd  0x0                                                                        // 0xA1B  (0x100)
  retd  0x0                                                                        // 0xA1C  (0x100)
  retd  0x0                                                                        // 0xA1D  (0x100)
  retd  0x0                                                                        // 0xA1E  (0x100)
  retd  0x0                                                                        // 0xA1F  (0x100)
  retd  0x0                                                                        // 0xA20  (0x100)
  retd  0x15                                                                       // 0xA21  (0x115)
  retd  0x3                                                                        // 0xA22  (0x103)
  retd  0x87                                                                       // 0xA23  (0x187)
  retd  0xB9                                                                       // 0xA24  (0x1B9)
  retd  0x25                                                                       // 0xA25  (0x125)
  retd  0xA9                                                                       // 0xA26  (0x1A9)
  retd  0xB1                                                                       // 0xA27  (0x1B1)
  retd  0x47                                                                       // 0xA28  (0x147)
  retd  0x78                                                                       // 0xA29  (0x178)
  retd  0x88                                                                       // 0xA2A  (0x188)
  retd  0x0                                                                        // 0xA2B  (0x100)
  retd  0x0                                                                        // 0xA2C  (0x100)
  retd  0x0                                                                        // 0xA2D  (0x100)
  retd  0x0                                                                        // 0xA2E  (0x100)
  retd  0x0                                                                        // 0xA2F  (0x100)
  retd  0x0                                                                        // 0xA30  (0x100)
  retd  0x13                                                                       // 0xA31  (0x113)
  retd  0x2                                                                        // 0xA32  (0x102)
  retd  0x44                                                                       // 0xA33  (0x144)
  retd  0x65                                                                       // 0xA34  (0x165)
  retd  0x87                                                                       // 0xA35  (0x187)
  retd  0x99                                                                       // 0xA36  (0x199)
  retd  0xA1                                                                       // 0xA37  (0x1A1)
  retd  0xCB                                                                       // 0xA38  (0x1CB)
  retd  0xBB                                                                       // 0xA39  (0x1BB)
  retd  0xBB                                                                       // 0xA3A  (0x1BB)
  retd  0x0                                                                        // 0xA3B  (0x100)
  retd  0x0                                                                        // 0xA3C  (0x100)
  retd  0x0                                                                        // 0xA3D  (0x100)
  retd  0x0                                                                        // 0xA3E  (0x100)
  retd  0x0                                                                        // 0xA3F  (0x100)
  retd  0x0                                                                        // 0xA40  (0x100)
  retd  0x10                                                                       // 0xA41  (0x110)
  retd  0x3                                                                        // 0xA42  (0x103)
  retd  0x65                                                                       // 0xA43  (0x165)
  retd  0x47                                                                       // 0xA44  (0x147)
  retd  0x22                                                                       // 0xA45  (0x122)
  retd  0x77                                                                       // 0xA46  (0x177)
  retd  0x42                                                                       // 0xA47  (0x142)
  retd  0x87                                                                       // 0xA48  (0x187)
  retd  0x78                                                                       // 0xA49  (0x178)
  retd  0x88                                                                       // 0xA4A  (0x188)
  retd  0x0                                                                        // 0xA4B  (0x100)
  retd  0x0                                                                        // 0xA4C  (0x100)
  retd  0x0                                                                        // 0xA4D  (0x100)
  retd  0x0                                                                        // 0xA4E  (0x100)
  retd  0x0                                                                        // 0xA4F  (0x100)
  retd  0x0                                                                        // 0xA50  (0x100)
  retd  0x11                                                                       // 0xA51  (0x111)
  retd  0x2                                                                        // 0xA52  (0x102)
  retd  0x33                                                                       // 0xA53  (0x133)
  retd  0x24                                                                       // 0xA54  (0x124)
  retd  0x51                                                                       // 0xA55  (0x151)
  retd  0x76                                                                       // 0xA56  (0x176)
  retd  0x81                                                                       // 0xA57  (0x181)
  retd  0x76                                                                       // 0xA58  (0x176)
  retd  0x66                                                                       // 0xA59  (0x166)
  retd  0x66                                                                       // 0xA5A  (0x166)
  retd  0x0                                                                        // 0xA5B  (0x100)
  retd  0x0                                                                        // 0xA5C  (0x100)
  retd  0x0                                                                        // 0xA5D  (0x100)
  retd  0x0                                                                        // 0xA5E  (0x100)
  retd  0x0                                                                        // 0xA5F  (0x100)
  retd  0x0                                                                        // 0xA60  (0x100)
  retd  0x21                                                                       // 0xA61  (0x121)
  retd  0x3                                                                        // 0xA62  (0x103)
  retd  0x44                                                                       // 0xA63  (0x144)
  retd  0x35                                                                       // 0xA64  (0x135)
  retd  0x11                                                                       // 0xA65  (0x111)
  retd  0x85                                                                       // 0xA66  (0x185)
  retd  0x60                                                                       // 0xA67  (0x160)
  retd  0x75                                                                       // 0xA68  (0x175)
  retd  0x75                                                                       // 0xA69  (0x175)
  retd  0x55                                                                       // 0xA6A  (0x155)
  retd  0x0                                                                        // 0xA6B  (0x100)
  retd  0x0                                                                        // 0xA6C  (0x100)
  retd  0x0                                                                        // 0xA6D  (0x100)
  retd  0x0                                                                        // 0xA6E  (0x100)
  retd  0x0                                                                        // 0xA6F  (0x100)
  retd  0x0                                                                        // 0xA70  (0x100)
  retd  0x10                                                                       // 0xA71  (0x110)
  retd  0x32                                                                       // 0xA72  (0x132)
  retd  0x55                                                                       // 0xA73  (0x155)
  retd  0x26                                                                       // 0xA74  (0x126)
  retd  0x77                                                                       // 0xA75  (0x177)
  retd  0x98                                                                       // 0xA76  (0x198)
  retd  0x47                                                                       // 0xA77  (0x147)
  retd  0x26                                                                       // 0xA78  (0x126)
  retd  0x66                                                                       // 0xA79  (0x166)
  retd  0x66                                                                       // 0xA7A  (0x166)
  retd  0x0                                                                        // 0xA7B  (0x100)
  retd  0x0                                                                        // 0xA7C  (0x100)
  retd  0x0                                                                        // 0xA7D  (0x100)
  retd  0x0                                                                        // 0xA7E  (0x100)
  retd  0x0                                                                        // 0xA7F  (0x100)
  retd  0x0                                                                        // 0xA80  (0x100)
  retd  0x10                                                                       // 0xA81  (0x110)
  retd  0x2                                                                        // 0xA82  (0x102)
  retd  0x33                                                                       // 0xA83  (0x133)
  retd  0x24                                                                       // 0xA84  (0x124)
  retd  0x76                                                                       // 0xA85  (0x176)
  retd  0x54                                                                       // 0xA86  (0x154)
  retd  0x80                                                                       // 0xA87  (0x180)
  retd  0x94                                                                       // 0xA88  (0x194)
  retd  0x94                                                                       // 0xA89  (0x194)
  retd  0x44                                                                       // 0xA8A  (0x144)
  retd  0x0                                                                        // 0xA8B  (0x100)
  retd  0x0                                                                        // 0xA8C  (0x100)
  retd  0x0                                                                        // 0xA8D  (0x100)
  retd  0x0                                                                        // 0xA8E  (0x100)
  retd  0x0                                                                        // 0xA8F  (0x100)
  retd  0x0                                                                        // 0xA90  (0x100)
  retd  0x21                                                                       // 0xA91  (0x121)
  retd  0x43                                                                       // 0xA92  (0x143)
  retd  0x55                                                                       // 0xA93  (0x155)
  retd  0x36                                                                       // 0xA94  (0x136)
  retd  0x87                                                                       // 0xA95  (0x187)
  retd  0x96                                                                       // 0xA96  (0x196)
  retd  0x3A                                                                       // 0xA97  (0x13A)
  retd  0xBB                                                                       // 0xA98  (0x1BB)
  retd  0x5B                                                                       // 0xA99  (0x15B)
  retd  0xBB                                                                       // 0xA9A  (0x1BB)
  retd  0x0                                                                        // 0xA9B  (0x100)
  retd  0x0                                                                        // 0xA9C  (0x100)
  retd  0x0                                                                        // 0xA9D  (0x100)
  retd  0x0                                                                        // 0xA9E  (0x100)
  retd  0x0                                                                        // 0xA9F  (0x100)
  retd  0x0                                                                        // 0xAA0  (0x100)
  retd  0x1                                                                        // 0xAA1  (0x101)
  retd  0x12                                                                       // 0xAA2  (0x112)
  retd  0x33                                                                       // 0xAA3  (0x133)
  retd  0x24                                                                       // 0xAA4  (0x124)
  retd  0x22                                                                       // 0xAA5  (0x122)
  retd  0x54                                                                       // 0xAA6  (0x154)
  retd  0x22                                                                       // 0xAA7  (0x122)
  retd  0x64                                                                       // 0xAA8  (0x164)
  retd  0x54                                                                       // 0xAA9  (0x154)
  retd  0x44                                                                       // 0xAAA  (0x144)
  retd  0x0                                                                        // 0xAAB  (0x100)
  retd  0x0                                                                        // 0xAAC  (0x100)
  retd  0x0                                                                        // 0xAAD  (0x100)
  retd  0x0                                                                        // 0xAAE  (0x100)
  retd  0x0                                                                        // 0xAAF  (0x100)
  retd  0x0                                                                        // 0xAB0  (0x100)
  retd  0x10                                                                       // 0xAB1  (0x110)
  retd  0x2                                                                        // 0xAB2  (0x102)
  retd  0x33                                                                       // 0xAB3  (0x133)
  retd  0x21                                                                       // 0xAB4  (0x121)
  retd  0x44                                                                       // 0xAB5  (0x144)
  retd  0x55                                                                       // 0xAB6  (0x155)
  retd  0x44                                                                       // 0xAB7  (0x144)
  retd  0x51                                                                       // 0xAB8  (0x151)
  retd  0x11                                                                       // 0xAB9  (0x111)
  retd  0x11                                                                       // 0xABA  (0x111)
  retd  0x11                                                                       // 0xABB  (0x111)
  retd  0x0                                                                        // 0xABC  (0x100)

jp_table_0xA00:
  jpba                                                                             // 0xABD  (0xFE8)

label_297:
  calz  zero_a_xp                                                                  // 0xABE  (0x5EF)
  ld    x,   0x4B                                                                  // 0xABF  (0xB4B)
  ld    a,   mx                                                                    // 0xAC0  (0xEC2)
  and   a,   0x1                                                                   // 0xAC1  (0xC81)
  xor   a,   0x1                                                                   // 0xAC2  (0xD01)
  ld    x,   0x78                                                                  // 0xAC3  (0xB78)
  ld    mx,  a                                                                     // 0xAC4  (0xEC8)
  ld    x,   0x90                                                                  // 0xAC5  (0xB90)
  pset  0xB                                                                        // 0xAC6  (0xE4B)
  call  label_309                                                                  // 0xAC7  (0x4F0)
  ld    b,   0xA                                                                   // 0xAC8  (0xE1A)
  pset  0xE                                                                        // 0xAC9  (0xE4E)
  call  label_352                                                                  // 0xACA  (0x45A)
  jp    nc,  label_298                                                             // 0xACB  (0x3CF)
  pset  0x5                                                                        // 0xACC  (0xE45)
  jp    nz,  label_159                                                             // 0xACD  (0x717)
  jp    label_300                                                                  // 0xACE  (0xD8)

label_298:
  calz  zero_b_xp                                                                  // 0xACF  (0x5F2)
  ld    x,   0x4B                                                                  // 0xAD0  (0xB4B)
  cp    a,   0x0                                                                   // 0xAD1  (0xDC0)
  jp    z,   label_299                                                             // 0xAD2  (0x6D7)
  ld    mx,  0x0                                                                   // 0xAD3  (0xE20)
  ld    a,   0x2                                                                   // 0xAD4  (0xE02)
  ld    xp,  a                                                                     // 0xAD5  (0xE80)
  ld    x,   0x5                                                                   // 0xAD6  (0xB05)

label_299:
  ld    mx,  0xF                                                                   // 0xAD7  (0xE2F)

label_300:
  pset  0x5                                                                        // 0xAD8  (0xE45)
  jp    label_160                                                                  // 0xAD9  (0x1A)

label_301:
  calz  check_0x04A_highbit                                                        // 0xADA  (0x5B3)
  jp    nz,  label_304                                                             // 0xADB  (0x7EE)
  ld    a,   0x2                                                                   // 0xADC  (0xE02)
  ld    xp,  a                                                                     // 0xADD  (0xE80)
  ld    x,   0x9                                                                   // 0xADE  (0xB09)
  cp    mx,  0x0                                                                   // 0xADF  (0xDE0)
  jp    z,   label_303                                                             // 0xAE0  (0x6E9)
  ld    mx,  0x0                                                                   // 0xAE1  (0xE20)
  calz  zero_a_xp                                                                  // 0xAE2  (0x5EF)
  ld    x,   0x43                                                                  // 0xAE3  (0xB43)
  add   mx,  0x4                                                                   // 0xAE4  (0xC24)
  jp    nc,  label_302                                                             // 0xAE5  (0x3E7)
  ld    mx,  0xF                                                                   // 0xAE6  (0xE2F)

label_302:
  ld    y,   0xF0                                                                  // 0xAE7  (0x8F0)
  calz  if_0x7B_set_clear_0x32_store_yhl_set_0x059_to_0xF                          // 0xAE8  (0x5BC)

label_303:
  ld    a,   0x8                                                                   // 0xAE9  (0xE08)
  ld    b,   0x5                                                                   // 0xAEA  (0xE15)
  ld    y,   0x3                                                                   // 0xAEB  (0x803)
  pset  0x8                                                                        // 0xAEC  (0xE48)
  call  label_273                                                                  // 0xAED  (0x4A9)

label_304:
  pset  0x5                                                                        // 0xAEE  (0xE45)
  jp    label_160                                                                  // 0xAEF  (0x1A)

label_305:
  ld    m0,  a                                                                     // 0xAF0  (0xF80)
  calz  zero_a_xp                                                                  // 0xAF1  (0x5EF)
  ld    x,   0x2A                                                                  // 0xAF2  (0xB2A)
  lbpx  mx,  0x0                                                                   // 0xAF3  (0x900)

label_306:
  calz  copy_video_buf_to_vram                                                     // 0xAF4  (0x556)
  calz  zero_a_xp                                                                  // 0xAF5  (0x5EF)
  ld    a,   m0                                                                    // 0xAF6  (0xFA0)
  ld    x,   0x2B                                                                  // 0xAF7  (0xB2B)
  cp    mx,  a                                                                     // 0xAF8  (0xF08)
  jp    nc,  ret_306                                                               // 0xAF9  (0x3FF)
  ld    x,   0x2A                                                                  // 0xAFA  (0xB2A)
  add   mx,  b                                                                     // 0xAFB  (0xA89)
  ldpx  a,   a                                                                     // 0xAFC  (0xEE0)
  adc   mx,  0x0                                                                   // 0xAFD  (0xC60)
  jp    label_306                                                                  // 0xAFE  (0xF4)

ret_306:
  ret                                                                              // 0xAFF  (0xFDF)
  
// Jump table for jp_table_0xB00
  retd  0x0                                                                        // 0xB00  (0x100)
  retd  0x0                                                                        // 0xB01  (0x100)
  retd  0xA1                                                                       // 0xB02  (0x1A1)
  retd  0x0                                                                        // 0xB03  (0x100)
  retd  0x0                                                                        // 0xB04  (0x100)
  retd  0x0                                                                        // 0xB05  (0x100)
  retd  0x0                                                                        // 0xB06  (0x100)
  retd  0x0                                                                        // 0xB07  (0x100)
  retd  0x0                                                                        // 0xB08  (0x100)
  retd  0x0                                                                        // 0xB09  (0x100)
  retd  0x0                                                                        // 0xB0A  (0x100)
  retd  0x0                                                                        // 0xB0B  (0x100)
  retd  0x0                                                                        // 0xB0C  (0x100)
  retd  0x0                                                                        // 0xB0D  (0x100)
  retd  0x0                                                                        // 0xB0E  (0x100)
  retd  0x0                                                                        // 0xB0F  (0x100)
  retd  0x0                                                                        // 0xB10  (0x100)
  retd  0x20                                                                       // 0xB11  (0x120)
  retd  0x0                                                                        // 0xB12  (0x100)
  retd  0x30                                                                       // 0xB13  (0x130)
  retd  0x11                                                                       // 0xB14  (0x111)
  retd  0x2                                                                        // 0xB15  (0x102)
  retd  0x5                                                                        // 0xB16  (0x105)
  retd  0x0                                                                        // 0xB17  (0x100)
  retd  0x0                                                                        // 0xB18  (0x100)
  retd  0x0                                                                        // 0xB19  (0x100)
  retd  0x0                                                                        // 0xB1A  (0x100)
  retd  0x0                                                                        // 0xB1B  (0x100)
  retd  0x0                                                                        // 0xB1C  (0x100)
  retd  0x0                                                                        // 0xB1D  (0x100)
  retd  0x0                                                                        // 0xB1E  (0x100)
  retd  0x0                                                                        // 0xB1F  (0x100)
  retd  0x0                                                                        // 0xB20  (0x100)
  retd  0x40                                                                       // 0xB21  (0x140)
  retd  0x0                                                                        // 0xB22  (0x100)
  retd  0x0                                                                        // 0xB23  (0x100)
  retd  0x11                                                                       // 0xB24  (0x111)
  retd  0x2                                                                        // 0xB25  (0x102)
  retd  0x0                                                                        // 0xB26  (0x100)
  retd  0x0                                                                        // 0xB27  (0x100)
  retd  0x3                                                                        // 0xB28  (0x103)
  retd  0x0                                                                        // 0xB29  (0x100)
  retd  0x0                                                                        // 0xB2A  (0x100)
  retd  0x0                                                                        // 0xB2B  (0x100)
  retd  0x0                                                                        // 0xB2C  (0x100)
  retd  0x0                                                                        // 0xB2D  (0x100)
  retd  0x0                                                                        // 0xB2E  (0x100)
  retd  0x0                                                                        // 0xB2F  (0x100)
  retd  0x0                                                                        // 0xB30  (0x100)
  retd  0x0                                                                        // 0xB31  (0x100)
  retd  0x7                                                                        // 0xB32  (0x107)
  retd  0x51                                                                       // 0xB33  (0x151)
  retd  0x11                                                                       // 0xB34  (0x111)
  retd  0x2                                                                        // 0xB35  (0x102)
  retd  0x5                                                                        // 0xB36  (0x105)
  retd  0x0                                                                        // 0xB37  (0x100)
  retd  0x6                                                                        // 0xB38  (0x106)
  retd  0x5                                                                        // 0xB39  (0x105)
  retd  0x0                                                                        // 0xB3A  (0x100)
  retd  0x0                                                                        // 0xB3B  (0x100)
  retd  0x0                                                                        // 0xB3C  (0x100)
  retd  0x0                                                                        // 0xB3D  (0x100)
  retd  0x0                                                                        // 0xB3E  (0x100)
  retd  0x0                                                                        // 0xB3F  (0x100)
  retd  0x0                                                                        // 0xB40  (0x100)
  retd  0x60                                                                       // 0xB41  (0x160)
  retd  0x0                                                                        // 0xB42  (0x100)
  retd  0x0                                                                        // 0xB43  (0x100)
  retd  0x11                                                                       // 0xB44  (0x111)
  retd  0x4                                                                        // 0xB45  (0x104)
  retd  0x5                                                                        // 0xB46  (0x105)
  retd  0x0                                                                        // 0xB47  (0x100)
  retd  0x0                                                                        // 0xB48  (0x100)
  retd  0x0                                                                        // 0xB49  (0x100)
  retd  0x0                                                                        // 0xB4A  (0x100)
  retd  0x0                                                                        // 0xB4B  (0x100)
  retd  0x0                                                                        // 0xB4C  (0x100)
  retd  0x0                                                                        // 0xB4D  (0x100)
  retd  0x0                                                                        // 0xB4E  (0x100)
  retd  0x0                                                                        // 0xB4F  (0x100)
  retd  0x0                                                                        // 0xB50  (0x100)
  retd  0x5                                                                        // 0xB51  (0x105)
  retd  0x7                                                                        // 0xB52  (0x107)
  retd  0x0                                                                        // 0xB53  (0x100)
  retd  0x11                                                                       // 0xB54  (0x111)
  retd  0x2                                                                        // 0xB55  (0x102)
  retd  0x0                                                                        // 0xB56  (0x100)
  retd  0x0                                                                        // 0xB57  (0x100)
  retd  0x0                                                                        // 0xB58  (0x100)
  retd  0x5                                                                        // 0xB59  (0x105)
  retd  0x0                                                                        // 0xB5A  (0x100)
  retd  0x0                                                                        // 0xB5B  (0x100)
  retd  0x0                                                                        // 0xB5C  (0x100)
  retd  0x0                                                                        // 0xB5D  (0x100)
  retd  0x0                                                                        // 0xB5E  (0x100)
  retd  0x0                                                                        // 0xB5F  (0x100)
  retd  0x0                                                                        // 0xB60  (0x100)
  retd  0x70                                                                       // 0xB61  (0x170)
  retd  0x7                                                                        // 0xB62  (0x107)
  retd  0x80                                                                       // 0xB63  (0x180)
  retd  0x11                                                                       // 0xB64  (0x111)
  retd  0x4                                                                        // 0xB65  (0x104)
  retd  0x0                                                                        // 0xB66  (0x100)
  retd  0x0                                                                        // 0xB67  (0x100)
  retd  0x0                                                                        // 0xB68  (0x100)
  retd  0x0                                                                        // 0xB69  (0x100)
  retd  0x0                                                                        // 0xB6A  (0x100)
  retd  0x0                                                                        // 0xB6B  (0x100)
  retd  0x0                                                                        // 0xB6C  (0x100)
  retd  0x0                                                                        // 0xB6D  (0x100)
  retd  0x0                                                                        // 0xB6E  (0x100)
  retd  0x0                                                                        // 0xB6F  (0x100)
  retd  0x0                                                                        // 0xB70  (0x100)
  retd  0x70                                                                       // 0xB71  (0x170)
  retd  0x7                                                                        // 0xB72  (0x107)
  retd  0x50                                                                       // 0xB73  (0x150)
  retd  0x11                                                                       // 0xB74  (0x111)
  retd  0x4                                                                        // 0xB75  (0x104)
  retd  0x0                                                                        // 0xB76  (0x100)
  retd  0x0                                                                        // 0xB77  (0x100)
  retd  0x0                                                                        // 0xB78  (0x100)
  retd  0x5                                                                        // 0xB79  (0x105)
  retd  0x0                                                                        // 0xB7A  (0x100)
  retd  0x0                                                                        // 0xB7B  (0x100)
  retd  0x0                                                                        // 0xB7C  (0x100)
  retd  0x0                                                                        // 0xB7D  (0x100)
  retd  0x0                                                                        // 0xB7E  (0x100)
  retd  0x0                                                                        // 0xB7F  (0x100)
  retd  0x0                                                                        // 0xB80  (0x100)
  retd  0x40                                                                       // 0xB81  (0x140)
  retd  0x7                                                                        // 0xB82  (0x107)
  retd  0x50                                                                       // 0xB83  (0x150)
  retd  0x11                                                                       // 0xB84  (0x111)
  retd  0x2                                                                        // 0xB85  (0x102)
  retd  0x0                                                                        // 0xB86  (0x100)
  retd  0x0                                                                        // 0xB87  (0x100)
  retd  0x0                                                                        // 0xB88  (0x100)
  retd  0x0                                                                        // 0xB89  (0x100)
  retd  0x0                                                                        // 0xB8A  (0x100)
  retd  0x0                                                                        // 0xB8B  (0x100)
  retd  0x0                                                                        // 0xB8C  (0x100)
  retd  0x0                                                                        // 0xB8D  (0x100)
  retd  0x0                                                                        // 0xB8E  (0x100)
  retd  0x0                                                                        // 0xB8F  (0x100)
  retd  0x0                                                                        // 0xB90  (0x100)
  retd  0x60                                                                       // 0xB91  (0x160)
  retd  0x0                                                                        // 0xB92  (0x100)
  retd  0x80                                                                       // 0xB93  (0x180)
  retd  0x11                                                                       // 0xB94  (0x111)
  retd  0x2                                                                        // 0xB95  (0x102)
  retd  0x0                                                                        // 0xB96  (0x100)
  retd  0x0                                                                        // 0xB97  (0x100)
  retd  0x0                                                                        // 0xB98  (0x100)
  retd  0x0                                                                        // 0xB99  (0x100)
  retd  0x0                                                                        // 0xB9A  (0x100)
  retd  0x0                                                                        // 0xB9B  (0x100)
  retd  0x0                                                                        // 0xB9C  (0x100)
  retd  0x0                                                                        // 0xB9D  (0x100)
  retd  0x0                                                                        // 0xB9E  (0x100)
  retd  0x0                                                                        // 0xB9F  (0x100)
  retd  0x0                                                                        // 0xBA0  (0x100)
  retd  0x0                                                                        // 0xBA1  (0x100)
  retd  0x7                                                                        // 0xBA2  (0x107)
  retd  0x50                                                                       // 0xBA3  (0x150)
  retd  0x11                                                                       // 0xBA4  (0x111)
  retd  0x4                                                                        // 0xBA5  (0x104)
  retd  0x0                                                                        // 0xBA6  (0x100)
  retd  0x5                                                                        // 0xBA7  (0x105)
  retd  0x0                                                                        // 0xBA8  (0x100)
  retd  0x5                                                                        // 0xBA9  (0x105)
  retd  0x0                                                                        // 0xBAA  (0x100)
  retd  0x0                                                                        // 0xBAB  (0x100)
  retd  0x0                                                                        // 0xBAC  (0x100)
  retd  0x0                                                                        // 0xBAD  (0x100)
  retd  0x0                                                                        // 0xBAE  (0x100)
  retd  0x0                                                                        // 0xBAF  (0x100)
  retd  0x0                                                                        // 0xBB0  (0x100)
  retd  0x90                                                                       // 0xBB1  (0x190)
  retd  0x7                                                                        // 0xBB2  (0x107)
  retd  0x50                                                                       // 0xBB3  (0x150)
  retd  0x11                                                                       // 0xBB4  (0x111)
  retd  0x4                                                                        // 0xBB5  (0x104)
  retd  0x5                                                                        // 0xBB6  (0x105)
  retd  0x5                                                                        // 0xBB7  (0x105)
  retd  0x0                                                                        // 0xBB8  (0x100)
  retd  0x5                                                                        // 0xBB9  (0x105)
  retd  0x0                                                                        // 0xBBA  (0x100)
  retd  0x0                                                                        // 0xBBB  (0x100)
  retd  0x0                                                                        // 0xBBC  (0x100)
  retd  0x0                                                                        // 0xBBD  (0x100)
  retd  0x0                                                                        // 0xBBE  (0x100)
  retd  0x0                                                                        // 0xBBF  (0x100)
  retd  0xCA                                                                       // 0xBC0  (0x1CA)
  retd  0xCD                                                                       // 0xBC1  (0x1CD)
  retd  0xD0                                                                       // 0xBC2  (0x1D0)
  retd  0xD3                                                                       // 0xBC3  (0x1D3)
  retd  0xD8                                                                       // 0xBC4  (0x1D8)
  retd  0xDB                                                                       // 0xBC5  (0x1DB)
  retd  0xDE                                                                       // 0xBC6  (0x1DE)
  retd  0xE3                                                                       // 0xBC7  (0x1E3)
  retd  0xE8                                                                       // 0xBC8  (0x1E8)
  retd  0xE8                                                                       // 0xBC9  (0x1E8)
  retd  0x1                                                                        // 0xBCA  (0x101)
  lbpx  mx,  0x31                                                                  // 0xBCB  (0x931)
  retd  0xCA                                                                       // 0xBCC  (0x1CA)
  retd  0x7                                                                        // 0xBCD  (0x107)
  lbpx  mx,  0x37                                                                  // 0xBCE  (0x937)
  retd  0xCE                                                                       // 0xBCF  (0x1CE)
  retd  0x0                                                                        // 0xBD0  (0x100)
  lbpx  mx,  0x30                                                                  // 0xBD1  (0x930)
  retd  0xD0                                                                       // 0xBD2  (0x1D0)
  retd  0x1                                                                        // 0xBD3  (0x101)
  retd  0x31                                                                       // 0xBD4  (0x131)
  retd  0x1                                                                        // 0xBD5  (0x101)
  lbpx  mx,  0xF1                                                                  // 0xBD6  (0x9F1)
  retd  0xD3                                                                       // 0xBD7  (0x1D3)
  retd  0x0                                                                        // 0xBD8  (0x100)
  lbpx  mx,  0xF0                                                                  // 0xBD9  (0x9F0)
  retd  0xD8                                                                       // 0xBDA  (0x1D8)
  retd  0x1                                                                        // 0xBDB  (0x101)
  lbpx  mx,  0xF1                                                                  // 0xBDC  (0x9F1)
  retd  0xDB                                                                       // 0xBDD  (0x1DB)
  retd  0x1                                                                        // 0xBDE  (0x101)
  retd  0x31                                                                       // 0xBDF  (0x131)
  retd  0x1                                                                        // 0xBE0  (0x101)
  lbpx  mx,  0xB1                                                                  // 0xBE1  (0x9B1)
  retd  0xDE                                                                       // 0xBE2  (0x1DE)
  retd  0x1                                                                        // 0xBE3  (0x101)
  retd  0x31                                                                       // 0xBE4  (0x131)
  retd  0x1                                                                        // 0xBE5  (0x101)
  lbpx  mx,  0x31                                                                  // 0xBE6  (0x931)
  retd  0xE6                                                                       // 0xBE7  (0x1E6)

label_308:
  lbpx  mx,  0xFF                                                                  // 0xBE8  (0x9FF)
  lbpx  mx,  0x28                                                                  // 0xBE9  (0x928)
  lbpx  mx,  0x29                                                                  // 0xBEA  (0x929)
  lbpx  mx,  0x2A                                                                  // 0xBEB  (0x92A)
  lbpx  mx,  0xFF                                                                  // 0xBEC  (0x9FF)
  lbpx  mx,  0x2B                                                                  // 0xBED  (0x92B)
  lbpx  mx,  0x2C                                                                  // 0xBEE  (0x92C)
  retd  0x2D                                                                       // 0xBEF  (0x12D)

label_309:
  lbpx  mx,  0xFF                                                                  // 0xBF0  (0x9FF)
  lbpx  mx,  0x38                                                                  // 0xBF1  (0x938)
  lbpx  mx,  0x39                                                                  // 0xBF2  (0x939)
  lbpx  mx,  0xFF                                                                  // 0xBF3  (0x9FF)
  lbpx  mx,  0xFF                                                                  // 0xBF4  (0x9FF)
  lbpx  mx,  0xE                                                                   // 0xBF5  (0x90E)
  lbpx  mx,  0x17                                                                  // 0xBF6  (0x917)
  retd  0xFF                                                                       // 0xBF7  (0x1FF)

label_310:
  lbpx  mx,  0x31                                                                  // 0xBF8  (0x931)
  lbpx  mx,  0x32                                                                  // 0xBF9  (0x932)
  lbpx  mx,  0x33                                                                  // 0xBFA  (0x933)
  retd  0xFF                                                                       // 0xBFB  (0x1FF)
  nop7                                                                             // 0xBFC  (0xFFF)
  nop7                                                                             // 0xBFD  (0xFFF)
  nop7                                                                             // 0xBFE  (0xFFF)
  nop7                                                                             // 0xBFF  (0xFFF)
  
// Jump table for jp_table_0xC00
  retd  0xC                                                                        // 0xC00  (0x10C)
  retd  0x11                                                                       // 0xC01  (0x111)
  retd  0x18                                                                       // 0xC02  (0x118)
  retd  0x24                                                                       // 0xC03  (0x124)
  retd  0x31                                                                       // 0xC04  (0x131)
  retd  0x3A                                                                       // 0xC05  (0x13A)
  retd  0x43                                                                       // 0xC06  (0x143)
  retd  0x4C                                                                       // 0xC07  (0x14C)
  retd  0x56                                                                       // 0xC08  (0x156)
  retd  0x60                                                                       // 0xC09  (0x160)
  retd  0x6C                                                                       // 0xC0A  (0x16C)
  retd  0x73                                                                       // 0xC0B  (0x173)
  retd  0x43                                                                       // 0xC0C  (0x143)
  retd  0x45                                                                       // 0xC0D  (0x145)
  retd  0x47                                                                       // 0xC0E  (0x147)
  retd  0x49                                                                       // 0xC0F  (0x149)
  retd  0x4B                                                                       // 0xC10  (0x14B)
  retd  0x7F                                                                       // 0xC11  (0x17F)
  retd  0x7F                                                                       // 0xC12  (0x17F)
  retd  0x7F                                                                       // 0xC13  (0x17F)
  retd  0x7F                                                                       // 0xC14  (0x17F)
  retd  0x7F                                                                       // 0xC15  (0x17F)
  retd  0x7F                                                                       // 0xC16  (0x17F)
  retd  0x7F                                                                       // 0xC17  (0x17F)
  retd  0xC                                                                        // 0xC18  (0x10C)
  retd  0x9                                                                        // 0xC19  (0x109)
  retd  0x9                                                                        // 0xC1A  (0x109)
  retd  0xA                                                                        // 0xC1B  (0x10A)
  retd  0xA                                                                        // 0xC1C  (0x10A)
  retd  0x7                                                                        // 0xC1D  (0x107)
  retd  0x8C                                                                       // 0xC1E  (0x18C)
  retd  0xD                                                                        // 0xC1F  (0x10D)
  retd  0xD                                                                        // 0xC20  (0x10D)
  retd  0xF                                                                        // 0xC21  (0x10F)
  retd  0x8F                                                                       // 0xC22  (0x18F)
  retd  0x10                                                                       // 0xC23  (0x110)
  retd  0xC                                                                        // 0xC24  (0x10C)
  retd  0x9                                                                        // 0xC25  (0x109)
  retd  0xA                                                                        // 0xC26  (0x10A)
  retd  0x11                                                                       // 0xC27  (0x111)
  retd  0xD                                                                        // 0xC28  (0x10D)
  retd  0xF                                                                        // 0xC29  (0x10F)
  retd  0x10                                                                       // 0xC2A  (0x110)
  retd  0x11                                                                       // 0xC2B  (0x111)
  retd  0x9                                                                        // 0xC2C  (0x109)
  retd  0xF                                                                        // 0xC2D  (0x10F)
  retd  0x10                                                                       // 0xC2E  (0x110)
  retd  0xD                                                                        // 0xC2F  (0x10D)
  retd  0xA                                                                        // 0xC30  (0x10A)
  retd  0x17                                                                       // 0xC31  (0x117)
  retd  0x18                                                                       // 0xC32  (0x118)
  retd  0x18                                                                       // 0xC33  (0x118)
  retd  0x19                                                                       // 0xC34  (0x119)
  retd  0x19                                                                       // 0xC35  (0x119)
  retd  0x1A                                                                       // 0xC36  (0x11A)
  retd  0x1A                                                                       // 0xC37  (0x11A)
  retd  0x9A                                                                       // 0xC38  (0x19A)
  retd  0x9A                                                                       // 0xC39  (0x19A)
  retd  0x20                                                                       // 0xC3A  (0x120)
  retd  0xA2                                                                       // 0xC3B  (0x1A2)
  retd  0x24                                                                       // 0xC3C  (0x124)
  retd  0xA6                                                                       // 0xC3D  (0x1A6)
  retd  0xA6                                                                       // 0xC3E  (0x1A6)
  retd  0x22                                                                       // 0xC3F  (0x122)
  retd  0xA6                                                                       // 0xC40  (0x1A6)
  retd  0x26                                                                       // 0xC41  (0x126)
  retd  0x24                                                                       // 0xC42  (0x124)
  retd  0x27                                                                       // 0xC43  (0x127)
  retd  0x28                                                                       // 0xC44  (0x128)
  retd  0x29                                                                       // 0xC45  (0x129)
  retd  0x2B                                                                       // 0xC46  (0x12B)
  retd  0x2C                                                                       // 0xC47  (0x12C)
  retd  0xAC                                                                       // 0xC48  (0x1AC)
  retd  0x2B                                                                       // 0xC49  (0x12B)
  retd  0xAC                                                                       // 0xC4A  (0x1AC)
  retd  0x2C                                                                       // 0xC4B  (0x12C)
  retd  0x2D                                                                       // 0xC4C  (0x12D)
  retd  0x2D                                                                       // 0xC4D  (0x12D)
  retd  0x30                                                                       // 0xC4E  (0x130)
  retd  0x31                                                                       // 0xC4F  (0x131)
  retd  0x30                                                                       // 0xC50  (0x130)
  retd  0x32                                                                       // 0xC51  (0x132)
  retd  0x32                                                                       // 0xC52  (0x132)
  retd  0x33                                                                       // 0xC53  (0x133)
  retd  0x34                                                                       // 0xC54  (0x134)
  retd  0xB4                                                                       // 0xC55  (0x1B4)
  retd  0x17                                                                       // 0xC56  (0x117)
  retd  0x18                                                                       // 0xC57  (0x118)
  retd  0x19                                                                       // 0xC58  (0x119)
  retd  0x1A                                                                       // 0xC59  (0x11A)
  retd  0x9A                                                                       // 0xC5A  (0x19A)
  retd  0x1A                                                                       // 0xC5B  (0x11A)
  retd  0xB8                                                                       // 0xC5C  (0x1B8)
  retd  0x38                                                                       // 0xC5D  (0x138)
  retd  0x19                                                                       // 0xC5E  (0x119)
  retd  0x9A                                                                       // 0xC5F  (0x19A)
  retd  0x17                                                                       // 0xC60  (0x117)
  retd  0x17                                                                       // 0xC61  (0x117)
  retd  0x18                                                                       // 0xC62  (0x118)
  retd  0x19                                                                       // 0xC63  (0x119)
  retd  0x17                                                                       // 0xC64  (0x117)
  retd  0x1A                                                                       // 0xC65  (0x11A)
  retd  0x9A                                                                       // 0xC66  (0x19A)
  retd  0x18                                                                       // 0xC67  (0x118)
  retd  0x98                                                                       // 0xC68  (0x198)
  retd  0x97                                                                       // 0xC69  (0x197)
  retd  0x98                                                                       // 0xC6A  (0x198)
  retd  0x9A                                                                       // 0xC6B  (0x19A)
  retd  0x35                                                                       // 0xC6C  (0x135)
  retd  0x35                                                                       // 0xC6D  (0x135)
  retd  0x36                                                                       // 0xC6E  (0x136)
  retd  0x37                                                                       // 0xC6F  (0x137)
  retd  0x37                                                                       // 0xC70  (0x137)
  retd  0xB7                                                                       // 0xC71  (0x1B7)
  retd  0x37                                                                       // 0xC72  (0x137)
  retd  0x3C                                                                       // 0xC73  (0x13C)
  retd  0x3E                                                                       // 0xC74  (0x13E)
  retd  0x40                                                                       // 0xC75  (0x140)
  retd  0x41                                                                       // 0xC76  (0x141)
  retd  0x42                                                                       // 0xC77  (0x142)
  retd  0x41                                                                       // 0xC78  (0x141)

jp_table_0xC00:
  jpba                                                                             // 0xC79  (0xFE8)

label_312:
  rst   f,   0xB                                                                   // 0xC7A  (0xF5B)
  ld    x,   0x7C                                                                  // 0xC7B  (0xB7C)
  cp    mx,  0x0                                                                   // 0xC7C  (0xDE0)
  jp    z,   label_313                                                             // 0xC7D  (0x681)
  cp    mx,  0xF                                                                   // 0xC7E  (0xDEF)
  jp    z,   label_314                                                             // 0xC7F  (0x682)
  add   mx,  0xF                                                                   // 0xC80  (0xC2F)

label_313:
  ret                                                                              // 0xC81  (0xFDF)

label_314:
  ld    x,   0x4A                                                                  // 0xC82  (0xB4A)
  fan   mx,  0x8                                                                   // 0xC83  (0xDA8)
  jp    z,   label_318                                                             // 0xC84  (0x696)
  calz  check_0xX5D_is_1                                                           // 0xC85  (0x5F8)
  ld    a,   0x2                                                                   // 0xC86  (0xE02)
  ld    xp,  a                                                                     // 0xC87  (0xE80)
  jp    nz,  label_316                                                             // 0xC88  (0x78E)
  ld    x,   0x15                                                                  // 0xC89  (0xB15)
  add   mx,  0xF                                                                   // 0xC8A  (0xC2F)
  jp    c,   label_315                                                             // 0xC8B  (0x28D)
  ld    mx,  0x0                                                                   // 0xC8C  (0xE20)

label_315:
  ret                                                                              // 0xC8D  (0xFDF)

label_316:
  ld    x,   0x4                                                                   // 0xC8E  (0xB04)
  add   mx,  0x1                                                                   // 0xC8F  (0xC21)
  ldpx  a,   a                                                                     // 0xC90  (0xEE0)
  adc   mx,  0x0                                                                   // 0xC91  (0xC60)
  jp    nc,  label_317                                                             // 0xC92  (0x395)
  ld    x,   0x4                                                                   // 0xC93  (0xB04)
  lbpx  mx,  0xFF                                                                  // 0xC94  (0x9FF)

label_317:
  ret                                                                              // 0xC95  (0xFDF)

label_318:
  calz  check_0xX5D_is_1                                                           // 0xC96  (0x5F8)
  ld    a,   0x2                                                                   // 0xC97  (0xE02)
  ld    xp,  a                                                                     // 0xC98  (0xE80)
  jp    nz,  label_319                                                             // 0xC99  (0x7A1)
  ld    x,   0x16                                                                  // 0xC9A  (0xB16)
  add   mx,  0xF                                                                   // 0xC9B  (0xC2F)
  ldpx  a,   a                                                                     // 0xC9C  (0xEE0)
  adc   mx,  0xF                                                                   // 0xC9D  (0xC6F)
  jp    c,   label_319                                                             // 0xC9E  (0x2A1)
  ld    x,   0x16                                                                  // 0xC9F  (0xB16)
  lbpx  mx,  0x0                                                                   // 0xCA0  (0x900)

label_319:
  ld    x,   0x0                                                                   // 0xCA1  (0xB00)
  call  label_326                                                                  // 0xCA2  (0x4D2)
  ld    x,   0x2                                                                   // 0xCA3  (0xB02)
  call  label_326                                                                  // 0xCA4  (0x4D2)
  ld    x,   0x8                                                                   // 0xCA5  (0xB08)
  call  label_328                                                                  // 0xCA6  (0x4D9)
  ld    x,   0x9                                                                   // 0xCA7  (0xB09)
  call  label_328                                                                  // 0xCA8  (0x4D9)
  ld    x,   0x6                                                                   // 0xCA9  (0xB06)
  call  label_326                                                                  // 0xCAA  (0x4D2)
  calz  zero_a_xp                                                                  // 0xCAB  (0x5EF)
  ld    x,   0x40                                                                  // 0xCAC  (0xB40)
  cp    mx,  0x0                                                                   // 0xCAD  (0xDE0)
  jp    z,   label_320                                                             // 0xCAE  (0x6B8)
  ld    x,   0x41                                                                  // 0xCAF  (0xB41)
  cp    mx,  0x0                                                                   // 0xCB0  (0xDE0)
  jp    z,   label_320                                                             // 0xCB1  (0x6B8)
  ld    a,   0x2                                                                   // 0xCB2  (0xE02)
  ld    xp,  a                                                                     // 0xCB3  (0xE80)
  ld    x,   0xA                                                                   // 0xCB4  (0xB0A)
  lbpx  mx,  0x0                                                                   // 0xCB5  (0x900)
  ld    mx,  0x0                                                                   // 0xCB6  (0xE20)
  jp    label_321                                                                  // 0xCB7  (0xBC)

label_320:
  ld    a,   0x2                                                                   // 0xCB8  (0xE02)
  ld    xp,  a                                                                     // 0xCB9  (0xE80)
  ld    x,   0xA                                                                   // 0xCBA  (0xB0A)
  call  label_330                                                                  // 0xCBB  (0x4DF)

label_321:
  calz  zero_a_xp_and_bit_high_at_0x048                                            // 0xCBC  (0x5FB)
  jp    z,   label_322                                                             // 0xCBD  (0x6C3)
  ld    a,   0x2                                                                   // 0xCBE  (0xE02)
  ld    xp,  a                                                                     // 0xCBF  (0xE80)
  ld    x,   0xD                                                                   // 0xCC0  (0xB0D)
  call  label_330                                                                  // 0xCC1  (0x4DF)
  jp    label_323                                                                  // 0xCC2  (0xC7)

label_322:
  ld    a,   0x2                                                                   // 0xCC3  (0xE02)
  ld    xp,  a                                                                     // 0xCC4  (0xE80)
  ld    x,   0xD                                                                   // 0xCC5  (0xB0D)
  call  label_324                                                                  // 0xCC6  (0x4C8)

label_323:
  ld    x,   0x10                                                                  // 0xCC7  (0xB10)

label_324:
  add   mx,  0xF                                                                   // 0xCC8  (0xC2F)
  ldpx  a,   a                                                                     // 0xCC9  (0xEE0)
  adc   mx,  0xF                                                                   // 0xCCA  (0xC6F)
  ldpx  a,   a                                                                     // 0xCCB  (0xEE0)
  adc   mx,  0xF                                                                   // 0xCCC  (0xC6F)
  jp    c,   label_325                                                             // 0xCCD  (0x2D1)
  adc   xl,  0xE                                                                   // 0xCCE  (0xA1E)
  lbpx  mx,  0x0                                                                   // 0xCCF  (0x900)
  ld    mx,  0x0                                                                   // 0xCD0  (0xE20)

label_325:
  ret                                                                              // 0xCD1  (0xFDF)

label_326:
  add   mx,  0xF                                                                   // 0xCD2  (0xC2F)
  ldpx  a,   a                                                                     // 0xCD3  (0xEE0)
  adc   mx,  0xF                                                                   // 0xCD4  (0xC6F)
  jp    c,   label_327                                                             // 0xCD5  (0x2D8)
  adc   xl,  0xF                                                                   // 0xCD6  (0xA1F)
  lbpx  mx,  0x0                                                                   // 0xCD7  (0x900)

label_327:
  ret                                                                              // 0xCD8  (0xFDF)

label_328:
  cp    mx,  0x0                                                                   // 0xCD9  (0xDE0)
  jp    z,   label_329                                                             // 0xCDA  (0x6DE)
  add   mx,  0x1                                                                   // 0xCDB  (0xC21)
  jp    nc,  label_329                                                             // 0xCDC  (0x3DE)
  ld    mx,  0xF                                                                   // 0xCDD  (0xE2F)

label_329:
  ret                                                                              // 0xCDE  (0xFDF)

label_330:
  add   mx,  0x1                                                                   // 0xCDF  (0xC21)
  ldpx  a,   a                                                                     // 0xCE0  (0xEE0)
  adc   mx,  0x0                                                                   // 0xCE1  (0xC60)
  ldpx  a,   a                                                                     // 0xCE2  (0xEE0)
  adc   mx,  0x0                                                                   // 0xCE3  (0xC60)
  ret                                                                              // 0xCE4  (0xFDF)

label_331:
  add   mx,  0x4                                                                   // 0xCE5  (0xC24)
  jp    nc,  label_332                                                             // 0xCE6  (0x3E8)
  ld    mx,  0xF                                                                   // 0xCE7  (0xE2F)

label_332:
  ld    x,   0x40                                                                  // 0xCE8  (0xB40)
  cp    mx,  0x0                                                                   // 0xCE9  (0xDE0)
  jp    z,   label_333                                                             // 0xCEA  (0x6F4)
  ld    x,   0x41                                                                  // 0xCEB  (0xB41)
  cp    mx,  0x0                                                                   // 0xCEC  (0xDE0)
  jp    z,   label_333                                                             // 0xCED  (0x6F4)
  ld    a,   0x2                                                                   // 0xCEE  (0xE02)
  ld    xp,  a                                                                     // 0xCEF  (0xE80)
  ld    x,   0x8                                                                   // 0xCF0  (0xB08)
  ld    mx,  0x0                                                                   // 0xCF1  (0xE20)
  ld    a,   0x0                                                                   // 0xCF2  (0xE00)
  ld    xp,  a                                                                     // 0xCF3  (0xE80)

label_333:
  ret                                                                              // 0xCF4  (0xFDF)

label_334:
  lbpx  mx,  0x18                                                                  // 0xCF5  (0x918)
  lbpx  mx,  0xFF                                                                  // 0xCF6  (0x9FF)
  lbpx  mx,  0x1D                                                                  // 0xCF7  (0x91D)
  lbpx  mx,  0xFF                                                                  // 0xCF8  (0x9FF)
  lbpx  mx,  0x0                                                                   // 0xCF9  (0x900)
  lbpx  mx,  0xF                                                                   // 0xCFA  (0x90F)
  lbpx  mx,  0x0                                                                   // 0xCFB  (0x900)
  retd  0xFF                                                                       // 0xCFC  (0x1FF)
  nop7                                                                             // 0xCFD  (0xFFF)
  nop7                                                                             // 0xCFE  (0xFFF)
  nop7                                                                             // 0xCFF  (0xFFF)
  
// Jump table for jp_table_0xD00
  retd  0x10                                                                       // 0xD00  (0x110)
  retd  0x15                                                                       // 0xD01  (0x115)
  retd  0x1C                                                                       // 0xD02  (0x11C)
  retd  0x28                                                                       // 0xD03  (0x128)
  retd  0x35                                                                       // 0xD04  (0x135)
  retd  0x3E                                                                       // 0xD05  (0x13E)
  retd  0x47                                                                       // 0xD06  (0x147)
  retd  0x50                                                                       // 0xD07  (0x150)
  retd  0x5A                                                                       // 0xD08  (0x15A)
  retd  0x64                                                                       // 0xD09  (0x164)
  retd  0x70                                                                       // 0xD0A  (0x170)
  retd  0x77                                                                       // 0xD0B  (0x177)
  retd  0x7D                                                                       // 0xD0C  (0x17D)
  retd  0x7D                                                                       // 0xD0D  (0x17D)
  retd  0x7D                                                                       // 0xD0E  (0x17D)
  retd  0x7D                                                                       // 0xD0F  (0x17D)
  retd  0x44                                                                       // 0xD10  (0x144)
  retd  0x46                                                                       // 0xD11  (0x146)
  retd  0x48                                                                       // 0xD12  (0x148)
  retd  0x4A                                                                       // 0xD13  (0x14A)
  retd  0x4C                                                                       // 0xD14  (0x14C)
  retd  0x5                                                                        // 0xD15  (0x105)
  retd  0x1                                                                        // 0xD16  (0x101)
  retd  0x2                                                                        // 0xD17  (0x102)
  retd  0x3                                                                        // 0xD18  (0x103)
  retd  0x4                                                                        // 0xD19  (0x104)
  retd  0x0                                                                        // 0xD1A  (0x100)
  retd  0x6                                                                        // 0xD1B  (0x106)
  retd  0x8                                                                        // 0xD1C  (0x108)
  retd  0xB                                                                        // 0xD1D  (0x10B)
  retd  0x8                                                                        // 0xD1E  (0x108)
  retd  0x8                                                                        // 0xD1F  (0x108)
  retd  0xB                                                                        // 0xD20  (0x10B)
  retd  0x8                                                                        // 0xD21  (0x108)
  retd  0x8                                                                        // 0xD22  (0x108)
  retd  0x8                                                                        // 0xD23  (0x108)
  retd  0xB                                                                        // 0xD24  (0x10B)
  retd  0x8                                                                        // 0xD25  (0x108)
  retd  0x8                                                                        // 0xD26  (0x108)
  retd  0xB                                                                        // 0xD27  (0x10B)
  retd  0x14                                                                       // 0xD28  (0x114)
  retd  0x92                                                                       // 0xD29  (0x192)
  retd  0x13                                                                       // 0xD2A  (0x113)
  retd  0x12                                                                       // 0xD2B  (0x112)
  retd  0x15                                                                       // 0xD2C  (0x115)
  retd  0x13                                                                       // 0xD2D  (0x113)
  retd  0x12                                                                       // 0xD2E  (0x112)
  retd  0x13                                                                       // 0xD2F  (0x113)
  retd  0x93                                                                       // 0xD30  (0x193)
  retd  0x12                                                                       // 0xD31  (0x112)
  retd  0x16                                                                       // 0xD32  (0x116)
  retd  0x12                                                                       // 0xD33  (0x112)
  retd  0x92                                                                       // 0xD34  (0x192)
  retd  0x8                                                                        // 0xD35  (0x108)
  retd  0xB                                                                        // 0xD36  (0x10B)
  retd  0x8                                                                        // 0xD37  (0x108)
  retd  0x8                                                                        // 0xD38  (0x108)
  retd  0xB                                                                        // 0xD39  (0x10B)
  retd  0x8                                                                        // 0xD3A  (0x108)
  retd  0xB                                                                        // 0xD3B  (0x10B)
  retd  0x8                                                                        // 0xD3C  (0x108)
  retd  0xB                                                                        // 0xD3D  (0x10B)
  retd  0x21                                                                       // 0xD3E  (0x121)
  retd  0xA3                                                                       // 0xD3F  (0x1A3)
  retd  0x25                                                                       // 0xD40  (0x125)
  retd  0x15                                                                       // 0xD41  (0x115)
  retd  0x21                                                                       // 0xD42  (0x121)
  retd  0xA3                                                                       // 0xD43  (0x1A3)
  retd  0xA3                                                                       // 0xD44  (0x1A3)
  retd  0xA3                                                                       // 0xD45  (0x1A3)
  retd  0x16                                                                       // 0xD46  (0x116)
  retd  0x21                                                                       // 0xD47  (0x121)
  retd  0xA3                                                                       // 0xD48  (0x1A3)
  retd  0x2A                                                                       // 0xD49  (0x12A)
  retd  0x25                                                                       // 0xD4A  (0x125)
  retd  0x15                                                                       // 0xD4B  (0x115)
  retd  0x21                                                                       // 0xD4C  (0x121)
  retd  0x16                                                                       // 0xD4D  (0x116)
  retd  0x25                                                                       // 0xD4E  (0x125)
  retd  0x21                                                                       // 0xD4F  (0x121)
  retd  0x2E                                                                       // 0xD50  (0x12E)
  retd  0x2F                                                                       // 0xD51  (0x12F)
  retd  0x2F                                                                       // 0xD52  (0x12F)
  retd  0x2E                                                                       // 0xD53  (0x12E)
  retd  0xAE                                                                       // 0xD54  (0x1AE)
  retd  0x15                                                                       // 0xD55  (0x115)
  retd  0x2E                                                                       // 0xD56  (0x12E)
  retd  0x2E                                                                       // 0xD57  (0x12E)
  retd  0x2E                                                                       // 0xD58  (0x12E)
  retd  0x2E                                                                       // 0xD59  (0x12E)
  retd  0x21                                                                       // 0xD5A  (0x121)
  retd  0x25                                                                       // 0xD5B  (0x125)
  retd  0x25                                                                       // 0xD5C  (0x125)
  retd  0x15                                                                       // 0xD5D  (0x115)
  retd  0x21                                                                       // 0xD5E  (0x121)
  retd  0x21                                                                       // 0xD5F  (0x121)
  retd  0xA3                                                                       // 0xD60  (0x1A3)
  retd  0x23                                                                       // 0xD61  (0x123)
  retd  0x16                                                                       // 0xD62  (0x116)
  retd  0x25                                                                       // 0xD63  (0x125)
  retd  0x39                                                                       // 0xD64  (0x139)
  retd  0x3A                                                                       // 0xD65  (0x13A)
  retd  0x39                                                                       // 0xD66  (0x139)
  retd  0x39                                                                       // 0xD67  (0x139)
  retd  0x3B                                                                       // 0xD68  (0x13B)
  retd  0x3B                                                                       // 0xD69  (0x13B)
  retd  0x3A                                                                       // 0xD6A  (0x13A)
  retd  0x3B                                                                       // 0xD6B  (0x13B)
  retd  0x3B                                                                       // 0xD6C  (0x13B)
  retd  0x3A                                                                       // 0xD6D  (0x13A)
  retd  0xBA                                                                       // 0xD6E  (0x1BA)
  retd  0x3B                                                                       // 0xD6F  (0x13B)
  retd  0xAE                                                                       // 0xD70  (0x1AE)
  retd  0x2E                                                                       // 0xD71  (0x12E)
  retd  0xAE                                                                       // 0xD72  (0x1AE)
  retd  0x15                                                                       // 0xD73  (0x115)
  retd  0x2E                                                                       // 0xD74  (0x12E)
  retd  0x2E                                                                       // 0xD75  (0x12E)
  retd  0x2F                                                                       // 0xD76  (0x12F)
  retd  0x3D                                                                       // 0xD77  (0x13D)
  retd  0x3F                                                                       // 0xD78  (0x13F)
  retd  0x2F                                                                       // 0xD79  (0x12F)
  retd  0x15                                                                       // 0xD7A  (0x115)
  retd  0x2E                                                                       // 0xD7B  (0x12E)
  retd  0x3D                                                                       // 0xD7C  (0x13D)

jp_table_0xD00:
  jpba                                                                             // 0xD7D  (0xFE8)

label_336:
  calz  check_0x04A_highbit                                                        // 0xD7E  (0x5B3)
  jp    nz,  label_337                                                             // 0xD7F  (0x792)
  calz  one_a_xp                                                                   // 0xD80  (0x5F5)
  ld    x,   0x40                                                                  // 0xD81  (0xB40)
  call  label_338                                                                  // 0xD82  (0x494)
  ld    x,   0xC0                                                                  // 0xD83  (0xBC0)
  call  label_338                                                                  // 0xD84  (0x494)
  ld    a,   0x4                                                                   // 0xD85  (0xE04)
  ld    b,   0x4                                                                   // 0xD86  (0xE14)
  pset  0xA                                                                        // 0xD87  (0xE4A)
  call  label_305                                                                  // 0xD88  (0x4F0)
  ld    x,   0x4D                                                                  // 0xD89  (0xB4D)
  cp    mx,  0x0                                                                   // 0xD8A  (0xDE0)
  jp    z,   label_337                                                             // 0xD8B  (0x692)
  ld    mx,  0x0                                                                   // 0xD8C  (0xE20)
  ld    a,   0x7                                                                   // 0xD8D  (0xE07)
  ld    b,   0x5                                                                   // 0xD8E  (0xE15)
  ld    y,   0x6                                                                   // 0xD8F  (0x806)
  pset  0x8                                                                        // 0xD90  (0xE48)
  call  label_273                                                                  // 0xD91  (0x4A9)

label_337:
  pset  0x5                                                                        // 0xD92  (0xE45)
  jp    label_160                                                                  // 0xD93  (0x1A)

label_338:
  lbpx  mx,  0x44                                                                  // 0xD94  (0x944)
  lbpx  mx,  0xEE                                                                  // 0xD95  (0x9EE)
  lbpx  mx,  0xBB                                                                  // 0xD96  (0x9BB)
  lbpx  mx,  0x55                                                                  // 0xD97  (0x955)
  lbpx  mx,  0xAA                                                                  // 0xD98  (0x9AA)
  lbpx  mx,  0x11                                                                  // 0xD99  (0x911)
  lbpx  mx,  0x0                                                                   // 0xD9A  (0x900)
  retd  0x0                                                                        // 0xD9B  (0x100)

label_339:
  lbpx  mx,  0x0                                                                   // 0xD9C  (0x900)
  retd  0x21                                                                       // 0xD9D  (0x121)

label_340:
  lbpx  mx,  0x33                                                                  // 0xD9E  (0x933)
  lbpx  mx,  0x45                                                                  // 0xD9F  (0x945)
  lbpx  mx,  0x3                                                                   // 0xDA0  (0x903)
  lbpx  mx,  0x44                                                                  // 0xDA1  (0x944)
  lbpx  mx,  0x30                                                                  // 0xDA2  (0x930)
  lbpx  mx,  0x33                                                                  // 0xDA3  (0x933)
  lbpx  mx,  0x0                                                                   // 0xDA4  (0x900)
  retd  0x32                                                                       // 0xDA5  (0x132)

label_341:
  lbpx  mx,  0x43                                                                  // 0xDA6  (0x943)
  lbpx  mx,  0xAF                                                                  // 0xDA7  (0x9AF)
  lbpx  mx,  0x23                                                                  // 0xDA8  (0x923)
  lbpx  mx,  0x9F                                                                  // 0xDA9  (0x99F)
  lbpx  mx,  0x3                                                                   // 0xDAA  (0x903)
  lbpx  mx,  0x8F                                                                  // 0xDAB  (0x98F)
  lbpx  mx,  0x20                                                                  // 0xDAC  (0x920)
  lbpx  mx,  0x7F                                                                  // 0xDAD  (0x97F)
  lbpx  mx,  0x10                                                                  // 0xDAE  (0x910)
  lbpx  mx,  0x6F                                                                  // 0xDAF  (0x96F)
  lbpx  mx,  0x0                                                                   // 0xDB0  (0x900)
  retd  0x5F                                                                       // 0xDB1  (0x15F)

label_342:
  lbpx  mx,  0x84                                                                  // 0xDB2  (0x984)
  lbpx  mx,  0xAF                                                                  // 0xDB3  (0x9AF)
  lbpx  mx,  0x4                                                                   // 0xDB4  (0x904)
  lbpx  mx,  0x9F                                                                  // 0xDB5  (0x99F)
  lbpx  mx,  0x20                                                                  // 0xDB6  (0x920)
  lbpx  mx,  0x76                                                                  // 0xDB7  (0x976)
  lbpx  mx,  0x0                                                                   // 0xDB8  (0x900)
  retd  0x6F                                                                       // 0xDB9  (0x16F)

label_343:
  lbpx  mx,  0x30                                                                  // 0xDBA  (0x930)
  lbpx  mx,  0xAF                                                                  // 0xDBB  (0x9AF)
  lbpx  mx,  0x20                                                                  // 0xDBC  (0x920)
  lbpx  mx,  0x9F                                                                  // 0xDBD  (0x99F)
  lbpx  mx,  0x0                                                                   // 0xDBE  (0x900)
  retd  0x8F                                                                       // 0xDBF  (0x18F)

label_344:
  lbpx  mx,  0x60                                                                  // 0xDC0  (0x960)
  lbpx  mx,  0xAF                                                                  // 0xDC1  (0x9AF)
  lbpx  mx,  0x0                                                                   // 0xDC2  (0x900)
  retd  0x9F                                                                       // 0xDC3  (0x19F)

label_345:
  lbpx  mx,  0x0                                                                   // 0xDC4  (0x900)
  retd  0xBF                                                                       // 0xDC5  (0x1BF)

label_346:
  ld    x,   0x90                                                                  // 0xDC6  (0xB90)
  ld    b,   0x0                                                                   // 0xDC7  (0xE10)
  add   a,   0xB                                                                   // 0xDC8  (0xC0B)
  adc   b,   0xC                                                                   // 0xDC9  (0xC5C)
  jpba                                                                             // 0xDCA  (0xFE8)
  jp    label_339                                                                  // 0xDCB  (0x9C)
  jp    label_340                                                                  // 0xDCC  (0x9E)
  jp    label_341                                                                  // 0xDCD  (0xA6)
  jp    label_342                                                                  // 0xDCE  (0xB2)
  jp    label_343                                                                  // 0xDCF  (0xBA)
  jp    label_344                                                                  // 0xDD0  (0xC0)
  jp    label_345                                                                  // 0xDD1  (0xC4)

label_347:
  calz  zero_b_xp                                                                  // 0xDD2  (0x5F2)
  ld    yp,  b                                                                     // 0xDD3  (0xE91)
  ld    x,   0x49                                                                  // 0xDD4  (0xB49)
  ld    mx,  0x0                                                                   // 0xDD5  (0xE20)
  ld    x,   0x5D                                                                  // 0xDD6  (0xB5D)
  ld    a,   mx                                                                    // 0xDD7  (0xEC2)
  add   a,   0x8                                                                   // 0xDD8  (0xC08)
  adc   b,   0x5                                                                   // 0xDD9  (0xC55)
  ld    m0,  a                                                                     // 0xDDA  (0xF80)
  ld    m1,  b                                                                     // 0xDDB  (0xF91)
  ld    a,   0x5                                                                   // 0xDDC  (0xE05)
  ld    m2,  a                                                                     // 0xDDD  (0xF82)
  ld    a,   0x2                                                                   // 0xDDE  (0xE02)
  ld    xp,  a                                                                     // 0xDDF  (0xE80)
  ld    x,   0x30                                                                  // 0xDE0  (0xB30)
  calz  render_asset                                                               // 0xDE1  (0x500)
  ld    y,   0x48                                                                  // 0xDE2  (0x848)
  ld    a,   my                                                                    // 0xDE3  (0xEC3)
  ld    b,   0x2                                                                   // 0xDE4  (0xE12)
  ld    yp,  b                                                                     // 0xDE5  (0xE91)
  ld    x,   0x10                                                                  // 0xDE6  (0xB10)
  ld    y,   0x40                                                                  // 0xDE7  (0x840)
  calz  clear_0x07D                                                                // 0xDE8  (0x512)
  calz  copy_3_mx_my_ret                                                           // 0xDE9  (0x599)
  fan   a,   0x8                                                                   // 0xDEA  (0xD88)
  jp    nz,  label_348                                                             // 0xDEB  (0x7EF)
  ld    x,   0xD                                                                   // 0xDEC  (0xB0D)
  ld    y,   0x38                                                                  // 0xDED  (0x838)
  calz  copy_3_mx_my_ret                                                           // 0xDEE  (0x599)

label_348:
  calz  set_f_0x07D                                                                // 0xDEF  (0x509)
  ld    y,   0x43                                                                  // 0xDF0  (0x843)
  ld    x,   0x13                                                                  // 0xDF1  (0xB13)
  ld    mx,  my                                                                    // 0xDF2  (0xECB)
  calz  zero_a_xp                                                                  // 0xDF3  (0x5EF)
  ld    y,   0x44                                                                  // 0xDF4  (0x844)
  ld    x,   0x43                                                                  // 0xDF5  (0xB43)
  ld    mx,  my                                                                    // 0xDF6  (0xECB)
  ld    x,   0x50                                                                  // 0xDF7  (0xB50)
  cp    mx,  0x2                                                                   // 0xDF8  (0xDE2)
  jp    z,   label_349                                                             // 0xDF9  (0x6FC)
  cp    mx,  0x4                                                                   // 0xDFA  (0xDE4)
  jp    nz,  label_350                                                             // 0xDFB  (0x7FE)

label_349:
  ld    x,   0x43                                                                  // 0xDFC  (0xB43)
  ld    mx,  0x8                                                                   // 0xDFD  (0xE28)

label_350:
  pset  0x6                                                                        // 0xDFE  (0xE46)
  jp    label_214                                                                  // 0xDFF  (0xE5)
  
// Jump table for jp_table_0xE00
  retd  0xE                                                                        // 0xE00  (0x10E)
  retd  0x11                                                                       // 0xE01  (0x111)
  retd  0x16                                                                       // 0xE02  (0x116)
  retd  0x1F                                                                       // 0xE03  (0x11F)
  retd  0x24                                                                       // 0xE04  (0x124)
  retd  0x24                                                                       // 0xE05  (0x124)
  retd  0x29                                                                       // 0xE06  (0x129)
  retd  0x2E                                                                       // 0xE07  (0x12E)
  retd  0x31                                                                       // 0xE08  (0x131)
  retd  0x3C                                                                       // 0xE09  (0x13C)
  retd  0x45                                                                       // 0xE0A  (0x145)
  retd  0x4E                                                                       // 0xE0B  (0x14E)
  retd  0x55                                                                       // 0xE0C  (0x155)

jp_table_0xE00:
  jpba                                                                             // 0xE0D  (0xFE8)
  

  lbpx  mx,  0xFF                                                                  // 0xE0E  (0x9FF)
  lbpx  mx,  0x50                                                                  // 0xE0F  (0x950)
  retd  0xE                                                                        // 0xE10  (0x10E)
  lbpx  mx,  0x60                                                                  // 0xE11  (0x960)
  retd  0x30                                                                       // 0xE12  (0x130)
  lbpx  mx,  0x61                                                                  // 0xE13  (0x961)
  lbpx  mx,  0x30                                                                  // 0xE14  (0x930)
  retd  0x11                                                                       // 0xE15  (0x111)
  lbpx  mx,  0xFF                                                                  // 0xE16  (0x9FF)
  retd  0x50                                                                       // 0xE17  (0x150)
  lbpx  mx,  0xFF                                                                  // 0xE18  (0x9FF)
  retd  0x50                                                                       // 0xE19  (0x150)
  lbpx  mx,  0x5E                                                                  // 0xE1A  (0x95E)
  retd  0xA8                                                                       // 0xE1B  (0x1A8)
  lbpx  mx,  0x5F                                                                  // 0xE1C  (0x95F)
  lbpx  mx,  0xA8                                                                  // 0xE1D  (0x9A8)
  retd  0x1A                                                                       // 0xE1E  (0x11A)
  lbpx  mx,  0x65                                                                  // 0xE1F  (0x965)
  retd  0x30                                                                       // 0xE20  (0x130)
  lbpx  mx,  0x64                                                                  // 0xE21  (0x964)
  lbpx  mx,  0x30                                                                  // 0xE22  (0x930)
  retd  0x1F                                                                       // 0xE23  (0x11F)
  lbpx  mx,  0x62                                                                  // 0xE24  (0x962)
  retd  0x30                                                                       // 0xE25  (0x130)
  lbpx  mx,  0x7F                                                                  // 0xE26  (0x97F)
  lbpx  mx,  0x50                                                                  // 0xE27  (0x950)
  retd  0x24                                                                       // 0xE28  (0x124)
  lbpx  mx,  0x7F                                                                  // 0xE29  (0x97F)
  retd  0x50                                                                       // 0xE2A  (0x150)
  lbpx  mx,  0x63                                                                  // 0xE2B  (0x963)
  lbpx  mx,  0x30                                                                  // 0xE2C  (0x930)
  retd  0x29                                                                       // 0xE2D  (0x129)
  lbpx  mx,  0xD7                                                                  // 0xE2E  (0x9D7)
  lbpx  mx,  0xB0                                                                  // 0xE2F  (0x9B0)
  retd  0x2E                                                                       // 0xE30  (0x12E)
  lbpx  mx,  0x10                                                                  // 0xE31  (0x910)
  retd  0x0                                                                        // 0xE32  (0x100)
  lbpx  mx,  0x10                                                                  // 0xE33  (0x910)
  retd  0x80                                                                       // 0xE34  (0x180)
  lbpx  mx,  0xD1                                                                  // 0xE35  (0x9D1)
  retd  0x80                                                                       // 0xE36  (0x180)
  lbpx  mx,  0xD2                                                                  // 0xE37  (0x9D2)
  retd  0x80                                                                       // 0xE38  (0x180)
  lbpx  mx,  0xD3                                                                  // 0xE39  (0x9D3)
  lbpx  mx,  0x80                                                                  // 0xE3A  (0x980)
  retd  0x39                                                                       // 0xE3B  (0x139)
  lbpx  mx,  0x10                                                                  // 0xE3C  (0x910)
  retd  0x0                                                                        // 0xE3D  (0x100)
  lbpx  mx,  0x10                                                                  // 0xE3E  (0x910)
  retd  0x80                                                                       // 0xE3F  (0x180)
  lbpx  mx,  0x52                                                                  // 0xE40  (0x952)
  retd  0x80                                                                       // 0xE41  (0x180)
  lbpx  mx,  0x53                                                                  // 0xE42  (0x953)
  lbpx  mx,  0x80                                                                  // 0xE43  (0x980)
  retd  0x42                                                                       // 0xE44  (0x142)
  lbpx  mx,  0x14                                                                  // 0xE45  (0x914)
  retd  0x0                                                                        // 0xE46  (0x100)
  lbpx  mx,  0x14                                                                  // 0xE47  (0x914)
  retd  0x80                                                                       // 0xE48  (0x180)
  lbpx  mx,  0xD5                                                                  // 0xE49  (0x9D5)
  retd  0x80                                                                       // 0xE4A  (0x180)
  lbpx  mx,  0xD6                                                                  // 0xE4B  (0x9D6)
  lbpx  mx,  0x80                                                                  // 0xE4C  (0x980)
  retd  0xE                                                                        // 0xE4D  (0x10E)
  lbpx  mx,  0x14                                                                  // 0xE4E  (0x914)
  retd  0x0                                                                        // 0xE4F  (0x100)
  lbpx  mx,  0x14                                                                  // 0xE50  (0x914)
  retd  0x80                                                                       // 0xE51  (0x180)
  lbpx  mx,  0x56                                                                  // 0xE52  (0x956)
  lbpx  mx,  0x80                                                                  // 0xE53  (0x980)
  retd  0xE                                                                        // 0xE54  (0x10E)
  lbpx  mx,  0x10                                                                  // 0xE55  (0x910)
  retd  0x0                                                                        // 0xE56  (0x100)
  lbpx  mx,  0xD0                                                                  // 0xE57  (0x9D0)
  lbpx  mx,  0x80                                                                  // 0xE58  (0x980)
  retd  0x57                                                                       // 0xE59  (0x157)

label_352:
  calz  zero_a_xp                                                                  // 0xE5A  (0x5EF)
  ld    a,   0x2                                                                   // 0xE5B  (0xE02)
  pset  0x1                                                                        // 0xE5C  (0xE41)
  call  label_66                                                                   // 0xE5D  (0x4EC)
  calz  label_30                                                                   // 0xE5E  (0x5CE)
  lbpx  mx,  0x40                                                                  // 0xE5F  (0x940)
  ld    x,   0x78                                                                  // 0xE60  (0xB78)
  ldpx  a,   mx                                                                    // 0xE61  (0xEE2)
  ld    x,   0x75                                                                  // 0xE62  (0xB75)
  ldpx  mx,  a                                                                     // 0xE63  (0xEE8)

label_353:
  pset  0x2                                                                        // 0xE64  (0xE42)
  call  label_94                                                                   // 0xE65  (0x4C3)
  jp    c,   label_355                                                             // 0xE66  (0x279)
  jp    z,   label_355                                                             // 0xE67  (0x679)
  ld    x,   0x90                                                                  // 0xE68  (0xB90)
  lbpx  mx,  0xFF                                                                  // 0xE69  (0x9FF)
  ld    x,   0x98                                                                  // 0xE6A  (0xB98)
  lbpx  mx,  0xFF                                                                  // 0xE6B  (0x9FF)
  ld    x,   0x90                                                                  // 0xE6C  (0xB90)
  cp    a,   0x0                                                                   // 0xE6D  (0xDC0)
  jp    z,   label_354                                                             // 0xE6E  (0x670)
  ld    x,   0x98                                                                  // 0xE6F  (0xB98)

label_354:
  lbpx  mx,  0x27                                                                  // 0xE70  (0x927)
  pset  0x7                                                                        // 0xE71  (0xE47)
  call  label_233                                                                  // 0xE72  (0x492)
  calz  copy_video_buf_to_vram                                                     // 0xE73  (0x556)
  pset  0xF                                                                        // 0xE74  (0xE4F)
  call  label_357                                                                  // 0xE75  (0x400)
  jp    z,   label_353                                                             // 0xE76  (0x664)
  calz  zero_a_xp                                                                  // 0xE77  (0x5EF)
  set   f,   0x1                                                                   // 0xE78  (0xF41)

label_355:
  ld    x,   0x78                                                                  // 0xE79  (0xB78)
  ldpx  mx,  a                                                                     // 0xE7A  (0xEE8)
  ret                                                                              // 0xE7B  (0xFDF)

jp_table_0xE00_2:
  jpba                                                                             // 0xE7C  (0xFE8)

  lbpx  mx,  0xFF                                                                  // 0xE7D  (0x9FF)
  lbpx  mx,  0x8                                                                   // 0xE7E  (0x908)
  retd  0x7D                                                                       // 0xE7F  (0x17D)
  lbpx  mx,  0x30                                                                  // 0xE80  (0x930)
  lbpx  mx,  0x3                                                                   // 0xE81  (0x903)
  retd  0x7D                                                                       // 0xE82  (0x17D)
  lbpx  mx,  0x0                                                                   // 0xE83  (0x900)
  retd  0x7                                                                        // 0xE84  (0x107)
  lbpx  mx,  0x0                                                                   // 0xE85  (0x900)
  retd  0x6                                                                        // 0xE86  (0x106)
  lbpx  mx,  0x0                                                                   // 0xE87  (0x900)
  retd  0x5                                                                        // 0xE88  (0x105)
  lbpx  mx,  0x0                                                                   // 0xE89  (0x900)
  retd  0x4                                                                        // 0xE8A  (0x104)
  lbpx  mx,  0x0                                                                   // 0xE8B  (0x900)
  retd  0x3                                                                        // 0xE8C  (0x103)
  lbpx  mx,  0x0                                                                   // 0xE8D  (0x900)
  retd  0x2                                                                        // 0xE8E  (0x102)
  lbpx  mx,  0x0                                                                   // 0xE8F  (0x900)
  retd  0x1                                                                        // 0xE90  (0x101)
  lbpx  mx,  0x0                                                                   // 0xE91  (0x900)
  lbpx  mx,  0x0                                                                   // 0xE92  (0x900)
  retd  0x7D                                                                       // 0xE93  (0x17D)
  lbpx  mx,  0x1                                                                   // 0xE94  (0x901)
  lbpx  mx,  0x4                                                                   // 0xE95  (0x904)
  retd  0x7D                                                                       // 0xE96  (0x17D)
  lbpx  mx,  0x1                                                                   // 0xE97  (0x901)
  retd  0x5                                                                        // 0xE98  (0x105)
  lbpx  mx,  0x1                                                                   // 0xE99  (0x901)
  retd  0x8                                                                        // 0xE9A  (0x108)
  lbpx  mx,  0x1                                                                   // 0xE9B  (0x901)
  lbpx  mx,  0x3                                                                   // 0xE9C  (0x903)
  retd  0x7D                                                                       // 0xE9D  (0x17D)
  lbpx  mx,  0x5                                                                   // 0xE9E  (0x905)
  retd  0x7                                                                        // 0xE9F  (0x107)
  lbpx  mx,  0x3                                                                   // 0xEA0  (0x903)
  retd  0x8                                                                        // 0xEA1  (0x108)
  lbpx  mx,  0xB                                                                   // 0xEA2  (0x90B)
  lbpx  mx,  0x7                                                                   // 0xEA3  (0x907)
  retd  0x7D                                                                       // 0xEA4  (0x17D)
  lbpx  mx,  0x1                                                                   // 0xEA5  (0x901)
  retd  0x2                                                                        // 0xEA6  (0x102)
  lbpx  mx,  0x1                                                                   // 0xEA7  (0x901)
  retd  0x8                                                                        // 0xEA8  (0x108)
  lbpx  mx,  0x7                                                                   // 0xEA9  (0x907)
  retd  0x3                                                                        // 0xEAA  (0x103)
  lbpx  mx,  0x7                                                                   // 0xEAB  (0x907)
  lbpx  mx,  0x8                                                                   // 0xEAC  (0x908)
  retd  0xA5                                                                       // 0xEAD  (0x1A5)
  lbpx  mx,  0x2                                                                   // 0xEAE  (0x902)
  retd  0x1                                                                        // 0xEAF  (0x101)
  lbpx  mx,  0x2                                                                   // 0xEB0  (0x902)
  retd  0x4                                                                        // 0xEB1  (0x104)
  lbpx  mx,  0x2                                                                   // 0xEB2  (0x902)
  retd  0x2                                                                        // 0xEB3  (0x102)
  lbpx  mx,  0x2                                                                   // 0xEB4  (0x902)
  retd  0x5                                                                        // 0xEB5  (0x105)
  lbpx  mx,  0x2                                                                   // 0xEB6  (0x902)
  retd  0x3                                                                        // 0xEB7  (0x103)
  lbpx  mx,  0x2                                                                   // 0xEB8  (0x902)
  retd  0x6                                                                        // 0xEB9  (0x106)
  lbpx  mx,  0x2                                                                   // 0xEBA  (0x902)
  retd  0x4                                                                        // 0xEBB  (0x104)
  lbpx  mx,  0x2                                                                   // 0xEBC  (0x902)
  lbpx  mx,  0x7                                                                   // 0xEBD  (0x907)
  retd  0xAE                                                                       // 0xEBE  (0x1AE)
  lbpx  mx,  0x12                                                                  // 0xEBF  (0x912)
  retd  0x3                                                                        // 0xEC0  (0x103)
  lbpx  mx,  0x19                                                                  // 0xEC1  (0x919)
  lbpx  mx,  0x8                                                                   // 0xEC2  (0x908)
  retd  0xBF                                                                       // 0xEC3  (0x1BF)
  lbpx  mx,  0x18                                                                  // 0xEC4  (0x918)
  retd  0x3                                                                        // 0xEC5  (0x103)
  lbpx  mx,  0x28                                                                  // 0xEC6  (0x928)
  lbpx  mx,  0x8                                                                   // 0xEC7  (0x908)
  retd  0xC4                                                                       // 0xEC8  (0x1C4)
  lbpx  mx,  0x1C                                                                  // 0xEC9  (0x91C)
  retd  0x3                                                                        // 0xECA  (0x103)
  lbpx  mx,  0x44                                                                  // 0xECB  (0x944)
  lbpx  mx,  0x8                                                                   // 0xECC  (0x908)
  retd  0xC9                                                                       // 0xECD  (0x1C9)
  lbpx  mx,  0x50                                                                  // 0xECE  (0x950)
  lbpx  mx,  0x3                                                                   // 0xECF  (0x903)
  retd  0x7D                                                                       // 0xED0  (0x17D)
  lbpx  mx,  0x3                                                                   // 0xED1  (0x903)
  retd  0x4                                                                        // 0xED2  (0x104)
  lbpx  mx,  0x2                                                                   // 0xED3  (0x902)
  lbpx  mx,  0x2                                                                   // 0xED4  (0x902)
  retd  0xD1                                                                       // 0xED5  (0x1D1)
  lbpx  mx,  0xC                                                                   // 0xED6  (0x90C)
  retd  0x2                                                                        // 0xED7  (0x102)
  lbpx  mx,  0xC                                                                   // 0xED8  (0x90C)
  retd  0x4                                                                        // 0xED9  (0x104)
  lbpx  mx,  0xC                                                                   // 0xEDA  (0x90C)
  retd  0x6                                                                        // 0xEDB  (0x106)
  lbpx  mx,  0xC                                                                   // 0xEDC  (0x90C)
  retd  0x4                                                                        // 0xEDD  (0x104)
  lbpx  mx,  0xC                                                                   // 0xEDE  (0x90C)
  retd  0x2                                                                        // 0xEDF  (0x102)
  lbpx  mx,  0xC                                                                   // 0xEE0  (0x90C)
  retd  0x8                                                                        // 0xEE1  (0x108)
  lbpx  mx,  0x10                                                                  // 0xEE2  (0x910)
  lbpx  mx,  0x1                                                                   // 0xEE3  (0x901)
  retd  0x7D                                                                       // 0xEE4  (0x17D)
  lbpx  mx,  0xC                                                                   // 0xEE5  (0x90C)
  retd  0x4                                                                        // 0xEE6  (0x104)
  lbpx  mx,  0x6                                                                   // 0xEE7  (0x906)
  retd  0x2                                                                        // 0xEE8  (0x102)
  lbpx  mx,  0xC                                                                   // 0xEE9  (0x90C)
  retd  0x3                                                                        // 0xEEA  (0x103)
  lbpx  mx,  0x6                                                                   // 0xEEB  (0x906)
  retd  0x4                                                                        // 0xEEC  (0x104)
  lbpx  mx,  0x10                                                                  // 0xEED  (0x910)
  lbpx  mx,  0x5                                                                   // 0xEEE  (0x905)
  retd  0x7D                                                                       // 0xEEF  (0x17D)
  lbpx  mx,  0x6                                                                   // 0xEF0  (0x906)
  retd  0x1                                                                        // 0xEF1  (0x101)
  lbpx  mx,  0x7                                                                   // 0xEF2  (0x907)
  retd  0x2                                                                        // 0xEF3  (0x102)
  lbpx  mx,  0x8                                                                   // 0xEF4  (0x908)
  retd  0x3                                                                        // 0xEF5  (0x103)
  lbpx  mx,  0xA                                                                   // 0xEF6  (0x90A)
  retd  0x4                                                                        // 0xEF7  (0x104)
  lbpx  mx,  0xC                                                                   // 0xEF8  (0x90C)
  retd  0x5                                                                        // 0xEF9  (0x105)
  lbpx  mx,  0xE                                                                   // 0xEFA  (0x90E)
  lbpx  mx,  0x6                                                                   // 0xEFB  (0x906)
  retd  0x7D                                                                       // 0xEFC  (0x17D)
  nop7                                                                             // 0xEFD  (0xFFF)
  nop7                                                                             // 0xEFE  (0xFFF)
  nop7                                                                             // 0xEFF  (0xFFF)

label_357:
  ld    a,   0x2                                                                   // 0xF00  (0xE02)
  ld    yp,  a                                                                     // 0xF01  (0xE90)
  calz  zero_a_xp                                                                  // 0xF02  (0x5EF)
  ld    x,   0x7C                                                                  // 0xF03  (0xB7C)
  cp    mx,  0xF                                                                   // 0xF04  (0xDEF)
  jp    nz,  label_385                                                             // 0xF05  (0x7D6)
  ld    x,   0x5C                                                                  // 0xF06  (0xB5C)
  cp    mx,  0x0                                                                   // 0xF07  (0xDE0)
  jp    nz,  label_385                                                             // 0xF08  (0x7D6)
  ld    x,   0x14                                                                  // 0xF09  (0xB14)
  calz  clear_0x07D                                                                // 0xF0A  (0x512)
  ldpx  a,   mx                                                                    // 0xF0B  (0xEE2)
  ld    b,   mx                                                                    // 0xF0C  (0xEC6)
  calz  set_f_0x07D                                                                // 0xF0D  (0x509)
  ld    x,   0x4A                                                                  // 0xF0E  (0xB4A)
  fan   mx,  0x8                                                                   // 0xF0F  (0xDA8)
  jp    z,   label_364                                                             // 0xF10  (0x64A)
  calz  check_0xX5D_is_1                                                           // 0xF11  (0x5F8)
  jp    nz,  label_358                                                             // 0xF12  (0x717)
  ld    y,   0x15                                                                  // 0xF13  (0x815)
  cp    my,  0x0                                                                   // 0xF14  (0xDF0)
  jp    z,   label_359                                                             // 0xF15  (0x61D)
  jp    label_385                                                                  // 0xF16  (0xD6)

label_358:
  ld    y,   0x31                                                                  // 0xF17  (0x831)
  call  label_386                                                                  // 0xF18  (0x4D9)
  jp    c,   label_361                                                             // 0xF19  (0x235)
  ld    y,   0x33                                                                  // 0xF1A  (0x833)
  call  label_386                                                                  // 0xF1B  (0x4D9)
  jp    nc,  label_361                                                             // 0xF1C  (0x335)

label_359:
  ld    x,   0x4B                                                                  // 0xF1D  (0xB4B)
  ld    mx,  0xF                                                                   // 0xF1E  (0xE2F)
  ld    x,   0x4A                                                                  // 0xF1F  (0xB4A)
  ld    mx,  0x0                                                                   // 0xF20  (0xE20)
  set   f,   0x4                                                                   // 0xF21  (0xF44)
  ld    x,   0x54                                                                  // 0xF22  (0xB54)
  add   mx,  0x1                                                                   // 0xF23  (0xC21)
  ldpx  a,   a                                                                     // 0xF24  (0xEE0)
  adc   mx,  0x0                                                                   // 0xF25  (0xC60)
  rst   f,   0xB                                                                   // 0xF26  (0xF5B)
  jp    nc,  label_360                                                             // 0xF27  (0x32A)
  ld    x,   0x54                                                                  // 0xF28  (0xB54)
  lbpx  mx,  0x99                                                                  // 0xF29  (0x999)

label_360:
  ld    x,   0x50                                                                  // 0xF2A  (0xB50)
  cp    mx,  0xF                                                                   // 0xF2B  (0xDEF)
  jp    nz,  label_385                                                             // 0xF2C  (0x7D6)
  ld    y,   0x10                                                                  // 0xF2D  (0x810)
  calz  label_32                                                                   // 0xF2E  (0x5D7)
  jp    nz,  label_385                                                             // 0xF2F  (0x7D6)
  ld    y,   0x34                                                                  // 0xF30  (0x834)
  call  label_363                                                                  // 0xF31  (0x43D)
  ld    y,   0x36                                                                  // 0xF32  (0x836)
  call  label_363                                                                  // 0xF33  (0x43D)
  jp    label_385                                                                  // 0xF34  (0xD6)

label_361:
  ld    y,   0x5                                                                   // 0xF35  (0x805)
  cp    my,  0xF                                                                   // 0xF36  (0xDFF)
  jp    z,   label_362                                                             // 0xF37  (0x63C)
  cp    my,  0x4                                                                   // 0xF38  (0xDF4)
  jp    c,   label_362                                                             // 0xF39  (0x23C)
  ld    my,  0xF                                                                   // 0xF3A  (0xE3F)
  call  label_388                                                                  // 0xF3B  (0x4DF)

label_362:
  jp    label_385                                                                  // 0xF3C  (0xD6)

label_363:
  ldpy  a,   my                                                                    // 0xF3D  (0xEF3)
  ld    b,   my                                                                    // 0xF3E  (0xEC7)
  rrc   b                                                                          // 0xF3F  (0xE8D)
  rrc   a                                                                          // 0xF40  (0xE8C)
  rrc   b                                                                          // 0xF41  (0xE8D)
  rrc   a                                                                          // 0xF42  (0xE8C)
  and   b,   0x3                                                                   // 0xF43  (0xC93)
  rst   f,   0xE                                                                   // 0xF44  (0xF5E)
  adc   yl,  0xF                                                                   // 0xF45  (0xA3F)
  sub   my,  a                                                                     // 0xF46  (0xAAC)
  ldpy  a,   a                                                                     // 0xF47  (0xEF0)
  sbc   my,  b                                                                     // 0xF48  (0xABD)
  ret                                                                              // 0xF49  (0xFDF)

label_364:
  calz  check_0xX5D_is_1                                                           // 0xF4A  (0x5F8)
  jp    nz,  label_365                                                             // 0xF4B  (0x753)
  ld    y,   0x15                                                                  // 0xF4C  (0x815)
  cp    my,  0x0                                                                   // 0xF4D  (0xDF0)
  jp    z,   label_367                                                             // 0xF4E  (0x65B)
  ld    y,   0x16                                                                  // 0xF4F  (0x816)
  calz  label_31                                                                   // 0xF50  (0x5D4)
  jp    nz,  label_367                                                             // 0xF51  (0x75B)
  jp    label_366                                                                  // 0xF52  (0x59)

label_365:
  ld    y,   0x33                                                                  // 0xF53  (0x833)
  call  label_386                                                                  // 0xF54  (0x4D9)
  jp    nc,  label_366                                                             // 0xF55  (0x359)
  ld    y,   0x31                                                                  // 0xF56  (0x831)
  call  label_386                                                                  // 0xF57  (0x4D9)
  jp    nc,  label_367                                                             // 0xF58  (0x35B)

label_366:
  ld    a,   0x1                                                                   // 0xF59  (0xE01)
  jp    label_384                                                                  // 0xF5A  (0xD4)

label_367:
  ld    x,   0x49                                                                  // 0xF5B  (0xB49)
  cp    mx,  0x3                                                                   // 0xF5C  (0xDE3)
  jp    nc,  label_371                                                             // 0xF5D  (0x374)
  calz  check_0xX5D_is_1                                                           // 0xF5E  (0x5F8)
  jp    nz,  label_368                                                             // 0xF5F  (0x763)
  calz  bit_high_at_0x048                                                          // 0xF60  (0x5FD)
  jp    z,   label_370                                                             // 0xF61  (0x671)
  jp    label_370                                                                  // 0xF62  (0x71)

label_368:
  ld    y,   0xC                                                                   // 0xF63  (0x80C)
  cp    my,  0x2                                                                   // 0xF64  (0xDF2)
  jp    c,   label_369                                                             // 0xF65  (0x269)
  ld    y,   0xB                                                                   // 0xF66  (0x80B)
  cp    my,  0xD                                                                   // 0xF67  (0xDFD)
  jp    nc,  label_371                                                             // 0xF68  (0x374)

label_369:
  calz  bit_high_at_0x048                                                          // 0xF69  (0x5FD)
  jp    z,   label_370                                                             // 0xF6A  (0x671)
  ld    y,   0xF                                                                   // 0xF6B  (0x80F)
  cp    my,  0x1                                                                   // 0xF6C  (0xDF1)
  jp    c,   label_370                                                             // 0xF6D  (0x271)
  ld    y,   0xE                                                                   // 0xF6E  (0x80E)
  cp    my,  0x6                                                                   // 0xF6F  (0xDF6)
  jp    nc,  label_371                                                             // 0xF70  (0x374)

label_370:
  ld    x,   0x4F                                                                  // 0xF71  (0xB4F)
  cp    mx,  0x5                                                                   // 0xF72  (0xDE5)
  jp    c,   label_372                                                             // 0xF73  (0x276)

label_371:
  ld    a,   0x6                                                                   // 0xF74  (0xE06)
  jp    label_384                                                                  // 0xF75  (0xD4)

label_372:
  ld    y,   0x10                                                                  // 0xF76  (0x810)
  calz  label_32                                                                   // 0xF77  (0x5D7)
  jp    nz,  label_374                                                             // 0xF78  (0x780)
  ld    x,   0x50                                                                  // 0xF79  (0xB50)
  cp    mx,  0xF                                                                   // 0xF7A  (0xDEF)
  jp    nc,  label_373                                                             // 0xF7B  (0x37E)
  ld    a,   0x5                                                                   // 0xF7C  (0xE05)
  jp    label_384                                                                  // 0xF7D  (0xD4)

label_373:
  ld    x,   0x4E                                                                  // 0xF7E  (0xB4E)
  ld    mx,  0xF                                                                   // 0xF7F  (0xE2F)

label_374:
  ld    y,   0x6                                                                   // 0xF80  (0x806)
  calz  label_31                                                                   // 0xF81  (0x5D4)
  jp    nz,  label_375                                                             // 0xF82  (0x785)
  ld    a,   0x4                                                                   // 0xF83  (0xE04)
  jp    label_384                                                                  // 0xF84  (0xD4)

label_375:
  calz  bit_high_at_0x048                                                          // 0xF85  (0x5FD)
  jp    nz,  label_376                                                             // 0xF86  (0x78D)
  ld    y,   0xD                                                                   // 0xF87  (0x80D)
  calz  label_32                                                                   // 0xF88  (0x5D7)
  jp    nz,  label_376                                                             // 0xF89  (0x78D)
  ld    mx,  0xF                                                                   // 0xF8A  (0xE2F)
  ld    x,   0x49                                                                  // 0xF8B  (0xB49)
  add   mx,  0x1                                                                   // 0xF8C  (0xC21)

label_376:
  ld    y,   0x0                                                                   // 0xF8D  (0x800)
  calz  label_31                                                                   // 0xF8E  (0x5D4)
  jp    nz,  label_378                                                             // 0xF8F  (0x7A2)
  ld    y,   0x34                                                                  // 0xF90  (0x834)
  ldpy  a,   my                                                                    // 0xF91  (0xEF3)
  ld    b,   my                                                                    // 0xF92  (0xEC7)
  ld    y,   0x0                                                                   // 0xF93  (0x800)
  calz  clear_0x07D                                                                // 0xF94  (0x512)
  ldpy  my,  a                                                                     // 0xF95  (0xEFC)
  ld    my,  b                                                                     // 0xF96  (0xECD)
  calz  set_f_0x07D                                                                // 0xF97  (0x509)
  ld    x,   0x40                                                                  // 0xF98  (0xB40)
  add   mx,  0xC                                                                   // 0xF99  (0xC2C)
  jp    c,   label_377                                                             // 0xF9A  (0x29E)
  ld    mx,  0x0                                                                   // 0xF9B  (0xE20)
  ld    a,   0x2                                                                   // 0xF9C  (0xE02)
  jp    label_384                                                                  // 0xF9D  (0xD4)

label_377:
  ld    y,   0x13                                                                  // 0xF9E  (0x813)
  add   my,  0xF                                                                   // 0xF9F  (0xC3F)
  jp    c,   label_378                                                             // 0xFA0  (0x2A2)
  ld    my,  0x0                                                                   // 0xFA1  (0xE30)

label_378:
  ld    y,   0x2                                                                   // 0xFA2  (0x802)
  calz  label_31                                                                   // 0xFA3  (0x5D4)
  jp    nz,  label_380                                                             // 0xFA4  (0x7B7)
  ld    y,   0x36                                                                  // 0xFA5  (0x836)
  ldpy  a,   my                                                                    // 0xFA6  (0xEF3)
  ld    b,   my                                                                    // 0xFA7  (0xEC7)
  ld    y,   0x2                                                                   // 0xFA8  (0x802)
  calz  clear_0x07D                                                                // 0xFA9  (0x512)
  ldpy  my,  a                                                                     // 0xFAA  (0xEFC)
  ld    my,  b                                                                     // 0xFAB  (0xECD)
  calz  set_f_0x07D                                                                // 0xFAC  (0x509)
  ld    x,   0x41                                                                  // 0xFAD  (0xB41)
  add   mx,  0xC                                                                   // 0xFAE  (0xC2C)
  jp    c,   label_379                                                             // 0xFAF  (0x2B3)
  ld    mx,  0x0                                                                   // 0xFB0  (0xE20)
  ld    a,   0x2                                                                   // 0xFB1  (0xE02)
  jp    label_384                                                                  // 0xFB2  (0xD4)

label_379:
  ld    y,   0x13                                                                  // 0xFB3  (0x813)
  add   my,  0xF                                                                   // 0xFB4  (0xC3F)
  jp    c,   label_380                                                             // 0xFB5  (0x2B7)
  ld    my,  0x0                                                                   // 0xFB6  (0xE30)

label_380:
  ld    y,   0x43                                                                  // 0xFB7  (0x843)
  ld    a,   my                                                                    // 0xFB8  (0xEC3)
  ld    y,   0x13                                                                  // 0xFB9  (0x813)
  cp    my,  0x0                                                                   // 0xFBA  (0xDF0)
  jp    nz,  label_381                                                             // 0xFBB  (0x7C6)
  ld    my,  a                                                                     // 0xFBC  (0xECC)
  ld    y,   0x14                                                                  // 0xFBD  (0x814)
  ld    x,   0x43                                                                  // 0xFBE  (0xB43)
  set   f,   0x1                                                                   // 0xFBF  (0xF41)
  adc   my,  mx                                                                    // 0xFC0  (0xA9E)
  jp    c,   label_381                                                             // 0xFC1  (0x2C6)
  calz  check_0xX5D_is_1                                                           // 0xFC2  (0x5F8)
  jp    z,   label_381                                                             // 0xFC3  (0x6C6)
  ld    a,   0x3                                                                   // 0xFC4  (0xE03)
  jp    label_384                                                                  // 0xFC5  (0xD4)

label_381:
  ld    y,   0x8                                                                   // 0xFC6  (0x808)
  cp    my,  0xF                                                                   // 0xFC7  (0xDFF)
  jp    nz,  label_382                                                             // 0xFC8  (0x7CD)
  ld    my,  0x0                                                                   // 0xFC9  (0xE30)
  calz  check_0xX5D_is_1                                                           // 0xFCA  (0x5F8)
  jp    z,   label_382                                                             // 0xFCB  (0x6CD)
  call  label_388                                                                  // 0xFCC  (0x4DF)

label_382:
  ld    y,   0x9                                                                   // 0xFCD  (0x809)
  cp    my,  0xF                                                                   // 0xFCE  (0xDFF)
  jp    nz,  label_383                                                             // 0xFCF  (0x7D3)
  ld    my,  0x0                                                                   // 0xFD0  (0xE30)
  ld    x,   0x51                                                                  // 0xFD1  (0xB51)
  call  label_389                                                                  // 0xFD2  (0x4E8)

label_383:
  jp    label_385                                                                  // 0xFD3  (0xD6)

label_384:
  ld    x,   0x5C                                                                  // 0xFD4  (0xB5C)
  ld    mx,  a                                                                     // 0xFD5  (0xEC8)

label_385:
  ld    x,   0x5C                                                                  // 0xFD6  (0xB5C)
  cp    mx,  0x0                                                                   // 0xFD7  (0xDE0)
  ret                                                                              // 0xFD8  (0xFDF)

label_386:
  cp    b,   my                                                                    // 0xFD9  (0xF07)
  jp    nz,  label_387                                                             // 0xFDA  (0x7DE)
  adc   yl,  0xF                                                                   // 0xFDB  (0xA3F)
  adc   yh,  0xF                                                                   // 0xFDC  (0xA2F)
  cp    a,   my                                                                    // 0xFDD  (0xF03)

label_387:
  ret                                                                              // 0xFDE  (0xFDF)

label_388:
  ld    x,   0x42                                                                  // 0xFDF  (0xB42)
  call  label_389                                                                  // 0xFE0  (0x4E8)
  ld    x,   0x50                                                                  // 0xFE1  (0xB50)
  cp    mx,  0xF                                                                   // 0xFE2  (0xDEF)
  jp    nz,  label_390                                                             // 0xFE3  (0x7EB)
  ld    y,   0x10                                                                  // 0xFE4  (0x810)
  calz  label_32                                                                   // 0xFE5  (0x5D7)
  jp    nz,  label_390                                                             // 0xFE6  (0x7EB)
  ld    x,   0x4F                                                                  // 0xFE7  (0xB4F)

label_389:
  add   mx,  0x1                                                                   // 0xFE8  (0xC21)
  jp    nc,  label_390                                                             // 0xFE9  (0x3EB)
  ld    mx,  0xF                                                                   // 0xFEA  (0xE2F)

label_390:
  ret                                                                              // 0xFEB  (0xFDF)

label_391:
  calz  zero_a_xp                                                                  // 0xFEC  (0x5EF)
  ld    x,   0x7C                                                                  // 0xFED  (0xB7C)
  ld    mx,  0xF                                                                   // 0xFEE  (0xE2F)
  ld    a,   0x6                                                                   // 0xFEF  (0xE06)
  ld    y,   0xD1                                                                  // 0xFF0  (0x8D1)
  calz  label_24                                                                   // 0xFF1  (0x5B7)
  ld    a,   0x2                                                                   // 0xFF2  (0xE02)
  ld    b,   0x4                                                                   // 0xFF3  (0xE14)
  pset  0x8                                                                        // 0xFF4  (0xE48)
  call  label_272                                                                  // 0xFF5  (0x4A8)
  calz  zero_a_xp                                                                  // 0xFF6  (0x5EF)
  ld    x,   0x74                                                                  // 0xFF7  (0xB74)
  ldpx  mx,  0xF                                                                   // 0xFF8  (0xE6F)
  ld    x,   0x5D                                                                  // 0xFF9  (0xB5D)
  lbpx  mx,  0x11                                                                  // 0xFFA  (0x911)
  pset  0x4                                                                        // 0xFFB  (0xE44)
  call  label_142                                                                  // 0xFFC  (0x465)
  pset  0xD                                                                        // 0xFFD  (0xE4D)
  jp    label_347                                                                  // 0xFFE  (0xD2)
  nop7                                                                             // 0xFFF  (0xFFF)
  
// Jump table for all of the images
  ld    a,   m0                                                                    // 0x1000 (0xFA0)
  ld    b,   m1                                                                    // 0x1001 (0xFB1)
  pset  0x10                                                                       // 0x1002 (0xE50)
  jpba                                                                             // 0x1003 (0xFE8)
  ld    a,   m0                                                                    // 0x1004 (0xFA0)
  ld    b,   m1                                                                    // 0x1005 (0xFB1)
  pset  0x11                                                                       // 0x1006 (0xE51)
  jpba                                                                             // 0x1007 (0xFE8)
  ld    a,   m0                                                                    // 0x1008 (0xFA0)
  ld    b,   m1                                                                    // 0x1009 (0xFB1)
  pset  0x12                                                                       // 0x100A (0xE52)
  jpba                                                                             // 0x100B (0xFE8)
  ld    a,   m0                                                                    // 0x100C (0xFA0)
  ld    b,   m1                                                                    // 0x100D (0xFB1)
  pset  0x13                                                                       // 0x100E (0xE53)
  jpba                                                                             // 0x100F (0xFE8)
  ld    a,   m0                                                                    // 0x1010 (0xFA0)
  ld    b,   m1                                                                    // 0x1011 (0xFB1)
  pset  0x14                                                                       // 0x1012 (0xE54)
  jpba                                                                             // 0x1013 (0xFE8)
  ld    a,   m0                                                                    // 0x1014 (0xFA0)
  ld    b,   m1                                                                    // 0x1015 (0xFB1)
  pset  0x15                                                                       // 0x1016 (0xE55)
  jpba                                                                             // 0x1017 (0xFE8)
  ld    a,   m0                                                                    // 0x1018 (0xFA0)
  ld    b,   m1                                                                    // 0x1019 (0xFB1)
  pset  0x16                                                                       // 0x101A (0xE56)
  jpba                                                                             // 0x101B (0xFE8)
  ld    a,   m0                                                                    // 0x101C (0xFA0)
  ld    b,   m1                                                                    // 0x101D (0xFB1)
  pset  0x17                                                                       // 0x101E (0xE57)
  jpba                                                                             // 0x101F (0xFE8)

gfx_jp_ret_zp:
  call  gfx_jp_table_jpba                                                          // 0x1020 (0x423)
  pset  0x0                                                                        // 0x1021 (0xE40)
  jp    set_f_0x07D                                                                // 0x1022 (0x9)

//
// Uses `jpba` to go to the jump table at 0x1000, to choose the graphic to render
//
gfx_jp_table_jpba:
  jpba                                                                             // 0x1023 (0xFE8)
  nop7                                                                             // 0x1024 (0xFFF)
  nop7                                                                             // 0x1025 (0xFFF)
  nop7                                                                             // 0x1026 (0xFFF)
  nop7                                                                             // 0x1027 (0xFFF)
  nop7                                                                             // 0x1028 (0xFFF)
  nop7                                                                             // 0x1029 (0xFFF)
  nop7                                                                             // 0x102A (0xFFF)
  nop7                                                                             // 0x102B (0xFFF)
  nop7                                                                             // 0x102C (0xFFF)
  nop7                                                                             // 0x102D (0xFFF)
  nop7                                                                             // 0x102E (0xFFF)
  nop7                                                                             // 0x102F (0xFFF)
  
  // Stage 0, Babytchi
  // Seems to be the same as 0x16C0, but there's clear padding around it
  lbpx  mx,  0x0                                                                   // 0x1030 (0x900)
  lbpx  mx,  0x0                                                                   // 0x1031 (0x900)
  lbpx  mx,  0x0                                                                   // 0x1032 (0x900)
  lbpx  mx,  0x0                                                                   // 0x1033 (0x900)
  lbpx  mx,  0x0                                                                   // 0x1034 (0x900)
  lbpx  mx,  0x3C                                                                  // 0x1035 (0x93C)
  lbpx  mx,  0x7A                                                                  // 0x1036 (0x97A)
  lbpx  mx,  0x6E                                                                  // 0x1037 (0x96E)
  lbpx  mx,  0x6E                                                                  // 0x1038 (0x96E)
  lbpx  mx,  0x7A                                                                  // 0x1039 (0x97A)
  lbpx  mx,  0x3C                                                                  // 0x103A (0x93C)
  lbpx  mx,  0x0                                                                   // 0x103B (0x900)
  lbpx  mx,  0x0                                                                   // 0x103C (0x900)
  lbpx  mx,  0x0                                                                   // 0x103D (0x900)
  lbpx  mx,  0x0                                                                   // 0x103E (0x900)
  retd  0x0                                                                        // 0x103F (0x100)
  
  // Stage 0, Babytchi hiding
  lbpx  mx,  0x0                                                                   // 0x1040 (0x900)
  lbpx  mx,  0x0                                                                   // 0x1041 (0x900)
  lbpx  mx,  0x0                                                                   // 0x1042 (0x900)
  lbpx  mx,  0x0                                                                   // 0x1043 (0x900)
  lbpx  mx,  0x80                                                                  // 0x1044 (0x980)
  lbpx  mx,  0xC0                                                                  // 0x1045 (0x9C0)
  lbpx  mx,  0xA0                                                                  // 0x1046 (0x9A0)
  lbpx  mx,  0xE0                                                                  // 0x1047 (0x9E0)
  lbpx  mx,  0xE0                                                                  // 0x1048 (0x9E0)
  lbpx  mx,  0xA0                                                                  // 0x1049 (0x9A0)
  lbpx  mx,  0xC0                                                                  // 0x104A (0x9C0)
  lbpx  mx,  0x80                                                                  // 0x104B (0x980)
  lbpx  mx,  0x0                                                                   // 0x104C (0x900)
  lbpx  mx,  0x0                                                                   // 0x104D (0x900)
  lbpx  mx,  0x0                                                                   // 0x104E (0x900)
  retd  0x0                                                                        // 0x104F (0x100)
  
  // Stage 0, Babytchi eating
  lbpx  mx,  0x0                                                                   // 0x1050 (0x900)
  lbpx  mx,  0x0                                                                   // 0x1051 (0x900)
  lbpx  mx,  0x0                                                                   // 0x1052 (0x900)
  lbpx  mx,  0x0                                                                   // 0x1053 (0x900)
  lbpx  mx,  0x0                                                                   // 0x1054 (0x900)
  lbpx  mx,  0x40                                                                  // 0x1055 (0x940)
  lbpx  mx,  0x43                                                                  // 0x1056 (0x943)
  lbpx  mx,  0x67                                                                  // 0x1057 (0x967)
  lbpx  mx,  0x7E                                                                  // 0x1058 (0x97E)
  lbpx  mx,  0x6E                                                                  // 0x1059 (0x96E)
  lbpx  mx,  0x38                                                                  // 0x105A (0x938)
  lbpx  mx,  0x0                                                                   // 0x105B (0x900)
  lbpx  mx,  0x0                                                                   // 0x105C (0x900)
  lbpx  mx,  0x0                                                                   // 0x105D (0x900)
  lbpx  mx,  0x0                                                                   // 0x105E (0x900)
  retd  0x0                                                                        // 0x105F (0x100)
  
  // Stage 0, Babytchi flattened
  lbpx  mx,  0x0                                                                   // 0x1060 (0x900)
  lbpx  mx,  0x0                                                                   // 0x1061 (0x900)
  lbpx  mx,  0x0                                                                   // 0x1062 (0x900)
  lbpx  mx,  0x0                                                                   // 0x1063 (0x900)
  lbpx  mx,  0xC0                                                                  // 0x1064 (0x9C0)
  lbpx  mx,  0xA0                                                                  // 0x1065 (0x9A0)
  lbpx  mx,  0xA0                                                                  // 0x1066 (0x9A0)
  lbpx  mx,  0xE0                                                                  // 0x1067 (0x9E0)
  lbpx  mx,  0xE0                                                                  // 0x1068 (0x9E0)
  lbpx  mx,  0xA0                                                                  // 0x1069 (0x9A0)
  lbpx  mx,  0xA0                                                                  // 0x106A (0x9A0)
  lbpx  mx,  0xC0                                                                  // 0x106B (0x9C0)
  lbpx  mx,  0x0                                                                   // 0x106C (0x900)
  lbpx  mx,  0x0                                                                   // 0x106D (0x900)
  lbpx  mx,  0x0                                                                   // 0x106E (0x900)
  retd  0x0                                                                        // 0x106F (0x100)
  
  // Stage 0, Babytchi happy
  lbpx  mx,  0x0                                                                   // 0x1070 (0x900)
  lbpx  mx,  0x0                                                                   // 0x1071 (0x900)
  lbpx  mx,  0x0                                                                   // 0x1072 (0x900)
  lbpx  mx,  0x0                                                                   // 0x1073 (0x900)
  lbpx  mx,  0x0                                                                   // 0x1074 (0x900)
  lbpx  mx,  0x1E                                                                  // 0x1075 (0x91E)
  lbpx  mx,  0x3D                                                                  // 0x1076 (0x93D)
  lbpx  mx,  0x27                                                                  // 0x1077 (0x927)
  lbpx  mx,  0x27                                                                  // 0x1078 (0x927)
  lbpx  mx,  0x3D                                                                  // 0x1079 (0x93D)
  lbpx  mx,  0x1E                                                                  // 0x107A (0x91E)
  lbpx  mx,  0x0                                                                   // 0x107B (0x900)
  lbpx  mx,  0x0                                                                   // 0x107C (0x900)
  lbpx  mx,  0x0                                                                   // 0x107D (0x900)
  lbpx  mx,  0x0                                                                   // 0x107E (0x900)
  retd  0x0                                                                        // 0x107F (0x100)
  
  // Stage 0, Babytchi looking left
  // I assume this is flipped to look right
  lbpx  mx,  0x0                                                                   // 0x1080 (0x900)
  lbpx  mx,  0x0                                                                   // 0x1081 (0x900)
  lbpx  mx,  0x0                                                                   // 0x1082 (0x900)
  lbpx  mx,  0x0                                                                   // 0x1083 (0x900)
  lbpx  mx,  0x0                                                                   // 0x1084 (0x900)
  lbpx  mx,  0x2C                                                                  // 0x1085 (0x92C)
  lbpx  mx,  0x6E                                                                  // 0x1086 (0x96E)
  lbpx  mx,  0x7A                                                                  // 0x1087 (0x97A)
  lbpx  mx,  0x7A                                                                  // 0x1088 (0x97A)
  lbpx  mx,  0x7E                                                                  // 0x1089 (0x97E)
  lbpx  mx,  0x3C                                                                  // 0x108A (0x93C)
  lbpx  mx,  0x0                                                                   // 0x108B (0x900)
  lbpx  mx,  0x0                                                                   // 0x108C (0x900)
  lbpx  mx,  0x0                                                                   // 0x108D (0x900)
  lbpx  mx,  0x0                                                                   // 0x108E (0x900)
  retd  0x0                                                                        // 0x108F (0x100)
  
  // Stage 0, Babytchi angry
  lbpx  mx,  0x0                                                                   // 0x1090 (0x900)
  lbpx  mx,  0x0                                                                   // 0x1091 (0x900)
  lbpx  mx,  0x0                                                                   // 0x1092 (0x900)
  lbpx  mx,  0x0                                                                   // 0x1093 (0x900)
  lbpx  mx,  0xE                                                                   // 0x1094 (0x90E)
  lbpx  mx,  0x3D                                                                  // 0x1095 (0x93D)
  lbpx  mx,  0x7B                                                                  // 0x1096 (0x97B)
  lbpx  mx,  0x4F                                                                  // 0x1097 (0x94F)
  lbpx  mx,  0x4F                                                                  // 0x1098 (0x94F)
  lbpx  mx,  0x7B                                                                  // 0x1099 (0x97B)
  lbpx  mx,  0x3D                                                                  // 0x109A (0x93D)
  lbpx  mx,  0xE                                                                   // 0x109B (0x90E)
  lbpx  mx,  0x0                                                                   // 0x109C (0x900)
  lbpx  mx,  0x0                                                                   // 0x109D (0x900)
  lbpx  mx,  0x0                                                                   // 0x109E (0x900)
  retd  0x0                                                                        // 0x109F (0x100)
  
  // Stage 1, Marutchi upper half
  lbpx  mx,  0x0                                                                   // 0x10A0 (0x900)
  lbpx  mx,  0x0                                                                   // 0x10A1 (0x900)
  lbpx  mx,  0x0                                                                   // 0x10A2 (0x900)
  lbpx  mx,  0xE0                                                                  // 0x10A3 (0x9E0)
  lbpx  mx,  0x10                                                                  // 0x10A4 (0x910)
  lbpx  mx,  0x8                                                                   // 0x10A5 (0x908)
  lbpx  mx,  0x28                                                                  // 0x10A6 (0x928)
  lbpx  mx,  0x88                                                                  // 0x10A7 (0x988)
  lbpx  mx,  0x88                                                                  // 0x10A8 (0x988)
  lbpx  mx,  0x28                                                                  // 0x10A9 (0x928)
  lbpx  mx,  0x8                                                                   // 0x10AA (0x908)
  lbpx  mx,  0x10                                                                  // 0x10AB (0x910)
  lbpx  mx,  0xE0                                                                  // 0x10AC (0x9E0)
  lbpx  mx,  0x0                                                                   // 0x10AD (0x900)
  lbpx  mx,  0x0                                                                   // 0x10AE (0x900)
  retd  0x0                                                                        // 0x10AF (0x100)
  
  // Stage 1, Marutchi lower half
  lbpx  mx,  0x0                                                                   // 0x10B0 (0x900)
  lbpx  mx,  0x0                                                                   // 0x10B1 (0x900)
  lbpx  mx,  0x0                                                                   // 0x10B2 (0x900)
  lbpx  mx,  0x3                                                                   // 0x10B3 (0x903)
  lbpx  mx,  0x4                                                                   // 0x10B4 (0x904)
  lbpx  mx,  0x8                                                                   // 0x10B5 (0x908)
  lbpx  mx,  0x8                                                                   // 0x10B6 (0x908)
  lbpx  mx,  0x8                                                                   // 0x10B7 (0x908)
  lbpx  mx,  0x8                                                                   // 0x10B8 (0x908)
  lbpx  mx,  0x8                                                                   // 0x10B9 (0x908)
  lbpx  mx,  0x8                                                                   // 0x10BA (0x908)
  lbpx  mx,  0x4                                                                   // 0x10BB (0x904)
  lbpx  mx,  0x3                                                                   // 0x10BC (0x903)
  lbpx  mx,  0x0                                                                   // 0x10BD (0x900)
  lbpx  mx,  0x0                                                                   // 0x10BE (0x900)
  retd  0x0                                                                        // 0x10BF (0x100)
  
  // Stage 1, Marutchi happy upper half
  lbpx  mx,  0x0                                                                   // 0x10C0 (0x900)
  lbpx  mx,  0x0                                                                   // 0x10C1 (0x900)
  lbpx  mx,  0x0                                                                   // 0x10C2 (0x900)
  lbpx  mx,  0xE0                                                                  // 0x10C3 (0x9E0)
  lbpx  mx,  0x10                                                                  // 0x10C4 (0x910)
  lbpx  mx,  0x28                                                                  // 0x10C5 (0x928)
  lbpx  mx,  0x8                                                                   // 0x10C6 (0x908)
  lbpx  mx,  0xC8                                                                  // 0x10C7 (0x9C8)
  lbpx  mx,  0xC8                                                                  // 0x10C8 (0x9C8)
  lbpx  mx,  0x8                                                                   // 0x10C9 (0x908)
  lbpx  mx,  0x28                                                                  // 0x10CA (0x928)
  lbpx  mx,  0x10                                                                  // 0x10CB (0x910)
  lbpx  mx,  0xE0                                                                  // 0x10CC (0x9E0)
  lbpx  mx,  0x0                                                                   // 0x10CD (0x900)
  lbpx  mx,  0x0                                                                   // 0x10CE (0x900)
  retd  0x0                                                                        // 0x10CF (0x100)
  
  // Stage 1, Marutchi eating upper half
  lbpx  mx,  0x0                                                                   // 0x10D0 (0x900)
  lbpx  mx,  0x0                                                                   // 0x10D1 (0x900)
  lbpx  mx,  0x0                                                                   // 0x10D2 (0x900)
  lbpx  mx,  0xC0                                                                  // 0x10D3 (0x9C0)
  lbpx  mx,  0x86                                                                  // 0x10D4 (0x986)
  lbpx  mx,  0xCD                                                                  // 0x10D5 (0x9CD)
  lbpx  mx,  0x99                                                                  // 0x10D6 (0x999)
  lbpx  mx,  0xF1                                                                  // 0x10D7 (0x9F1)
  lbpx  mx,  0x1                                                                   // 0x10D8 (0x901)
  lbpx  mx,  0x11                                                                  // 0x10D9 (0x911)
  lbpx  mx,  0x12                                                                  // 0x10DA (0x912)
  lbpx  mx,  0x4                                                                   // 0x10DB (0x904)
  lbpx  mx,  0xF8                                                                  // 0x10DC (0x9F8)
  lbpx  mx,  0x0                                                                   // 0x10DD (0x900)
  lbpx  mx,  0x0                                                                   // 0x10DE (0x900)
  retd  0x0                                                                        // 0x10DF (0x100)
  
  // Stage 1, Marutchi lower half
  // Not sure how this is different from 0x10B0
  lbpx  mx,  0x0                                                                   // 0x10E0 (0x900)
  lbpx  mx,  0x0                                                                   // 0x10E1 (0x900)
  lbpx  mx,  0x0                                                                   // 0x10E2 (0x900)
  lbpx  mx,  0x1                                                                   // 0x10E3 (0x901)
  lbpx  mx,  0x2                                                                   // 0x10E4 (0x902)
  lbpx  mx,  0x4                                                                   // 0x10E5 (0x904)
  lbpx  mx,  0x4                                                                   // 0x10E6 (0x904)
  lbpx  mx,  0x4                                                                   // 0x10E7 (0x904)
  lbpx  mx,  0x4                                                                   // 0x10E8 (0x904)
  lbpx  mx,  0x4                                                                   // 0x10E9 (0x904)
  lbpx  mx,  0x4                                                                   // 0x10EA (0x904)
  lbpx  mx,  0x2                                                                   // 0x10EB (0x902)
  lbpx  mx,  0x1                                                                   // 0x10EC (0x901)
  lbpx  mx,  0x0                                                                   // 0x10ED (0x900)
  lbpx  mx,  0x0                                                                   // 0x10EE (0x900)
  retd  0x0                                                                        // 0x10EF (0x100)
  
  // Stage 1, Marutchi looking left, upper half
  lbpx  mx,  0x0                                                                   // 0x10F0 (0x900)
  lbpx  mx,  0x0                                                                   // 0x10F1 (0x900)
  lbpx  mx,  0x0                                                                   // 0x10F2 (0x900)
  lbpx  mx,  0xE0                                                                  // 0x10F3 (0x9E0)
  lbpx  mx,  0x90                                                                  // 0x10F4 (0x990)
  lbpx  mx,  0x88                                                                  // 0x10F5 (0x988)
  lbpx  mx,  0x88                                                                  // 0x10F6 (0x988)
  lbpx  mx,  0x28                                                                  // 0x10F7 (0x928)
  lbpx  mx,  0x8                                                                   // 0x10F8 (0x908)
  lbpx  mx,  0x8                                                                   // 0x10F9 (0x908)
  lbpx  mx,  0x8                                                                   // 0x10FA (0x908)
  lbpx  mx,  0x10                                                                  // 0x10FB (0x910)
  lbpx  mx,  0xE0                                                                  // 0x10FC (0x9E0)
  lbpx  mx,  0x0                                                                   // 0x10FD (0x900)
  lbpx  mx,  0x0                                                                   // 0x10FE (0x900)
  retd  0x0                                                                        // 0x10FF (0x100)
  
  // Stage 1, Marutchi sleeping, upper half
  lbpx  mx,  0x0                                                                   // 0x1100 (0x900)
  lbpx  mx,  0x0                                                                   // 0x1101 (0x900)
  lbpx  mx,  0x0                                                                   // 0x1102 (0x900)
  lbpx  mx,  0xE0                                                                  // 0x1103 (0x9E0)
  lbpx  mx,  0x10                                                                  // 0x1104 (0x910)
  lbpx  mx,  0x28                                                                  // 0x1105 (0x928)
  lbpx  mx,  0x28                                                                  // 0x1106 (0x928)
  lbpx  mx,  0x88                                                                  // 0x1107 (0x988)
  lbpx  mx,  0x88                                                                  // 0x1108 (0x988)
  lbpx  mx,  0x28                                                                  // 0x1109 (0x928)
  lbpx  mx,  0x28                                                                  // 0x110A (0x928)
  lbpx  mx,  0x10                                                                  // 0x110B (0x910)
  lbpx  mx,  0xE0                                                                  // 0x110C (0x9E0)
  lbpx  mx,  0x0                                                                   // 0x110D (0x900)
  lbpx  mx,  0x0                                                                   // 0x110E (0x900)
  retd  0x0                                                                        // 0x110F (0x100)
  
  // Black screen. Turn on all pixels
  lbpx  mx,  0xFF                                                                  // 0x1110 (0x9FF)
  lbpx  mx,  0xFF                                                                  // 0x1111 (0x9FF)
  lbpx  mx,  0xFF                                                                  // 0x1112 (0x9FF)
  lbpx  mx,  0xFF                                                                  // 0x1113 (0x9FF)
  lbpx  mx,  0xFF                                                                  // 0x1114 (0x9FF)
  lbpx  mx,  0xFF                                                                  // 0x1115 (0x9FF)
  lbpx  mx,  0xFF                                                                  // 0x1116 (0x9FF)
  lbpx  mx,  0xFF                                                                  // 0x1117 (0x9FF)
  lbpx  mx,  0xFF                                                                  // 0x1118 (0x9FF)
  lbpx  mx,  0xFF                                                                  // 0x1119 (0x9FF)
  lbpx  mx,  0xFF                                                                  // 0x111A (0x9FF)
  lbpx  mx,  0xFF                                                                  // 0x111B (0x9FF)
  lbpx  mx,  0xFF                                                                  // 0x111C (0x9FF)
  lbpx  mx,  0xFF                                                                  // 0x111D (0x9FF)
  lbpx  mx,  0xFF                                                                  // 0x111E (0x9FF)
  retd  0xFF                                                                       // 0x111F (0x1FF)
  
  // Stage 1, Marutchi sleeping?, turned left, upper half
  lbpx  mx,  0x0                                                                   // 0x1120 (0x900)
  lbpx  mx,  0x0                                                                   // 0x1121 (0x900)
  lbpx  mx,  0x0                                                                   // 0x1122 (0x900)
  lbpx  mx,  0xE0                                                                  // 0x1123 (0x9E0)
  lbpx  mx,  0x90                                                                  // 0x1124 (0x990)
  lbpx  mx,  0x88                                                                  // 0x1125 (0x988)
  lbpx  mx,  0x88                                                                  // 0x1126 (0x988)
  lbpx  mx,  0x28                                                                  // 0x1127 (0x928)
  lbpx  mx,  0x28                                                                  // 0x1128 (0x928)
  lbpx  mx,  0x8                                                                   // 0x1129 (0x908)
  lbpx  mx,  0x8                                                                   // 0x112A (0x908)
  lbpx  mx,  0x10                                                                  // 0x112B (0x910)
  lbpx  mx,  0xE0                                                                  // 0x112C (0x9E0)
  lbpx  mx,  0x0                                                                   // 0x112D (0x900)
  lbpx  mx,  0x0                                                                   // 0x112E (0x900)
  retd  0x0                                                                        // 0x112F (0x100)
  
  // Stage 1, Marutchi happy, upper half
  lbpx  mx,  0x0                                                                   // 0x1130 (0x900)
  lbpx  mx,  0x0                                                                   // 0x1131 (0x900)
  lbpx  mx,  0x0                                                                   // 0x1132 (0x900)
  lbpx  mx,  0xFC                                                                  // 0x1133 (0x9FC)
  lbpx  mx,  0x2                                                                   // 0x1134 (0x902)
  lbpx  mx,  0x79                                                                  // 0x1135 (0x979)
  lbpx  mx,  0xF3                                                                  // 0x1136 (0x9F3)
  lbpx  mx,  0xF1                                                                  // 0x1137 (0x9F1)
  lbpx  mx,  0xF1                                                                  // 0x1138 (0x9F1)
  lbpx  mx,  0xF3                                                                  // 0x1139 (0x9F3)
  lbpx  mx,  0x79                                                                  // 0x113A (0x979)
  lbpx  mx,  0x2                                                                   // 0x113B (0x902)
  lbpx  mx,  0xFC                                                                  // 0x113C (0x9FC)
  lbpx  mx,  0x0                                                                   // 0x113D (0x900)
  lbpx  mx,  0x0                                                                   // 0x113E (0x900)
  retd  0x0                                                                        // 0x113F (0x100)
  
  // Stage 2a, Tamatchi upper half
  lbpx  mx,  0x0                                                                   // 0x1140 (0x900)
  lbpx  mx,  0x0                                                                   // 0x1141 (0x900)
  lbpx  mx,  0x0                                                                   // 0x1142 (0x900)
  lbpx  mx,  0xE0                                                                  // 0x1143 (0x9E0)
  lbpx  mx,  0x10                                                                  // 0x1144 (0x910)
  lbpx  mx,  0x8                                                                   // 0x1145 (0x908)
  lbpx  mx,  0x28                                                                  // 0x1146 (0x928)
  lbpx  mx,  0x88                                                                  // 0x1147 (0x988)
  lbpx  mx,  0x88                                                                  // 0x1148 (0x988)
  lbpx  mx,  0x28                                                                  // 0x1149 (0x928)
  lbpx  mx,  0x8                                                                   // 0x114A (0x908)
  lbpx  mx,  0x10                                                                  // 0x114B (0x910)
  lbpx  mx,  0xE0                                                                  // 0x114C (0x9E0)
  lbpx  mx,  0x0                                                                   // 0x114D (0x900)
  lbpx  mx,  0x0                                                                   // 0x114E (0x900)
  retd  0x0                                                                        // 0x114F (0x100)
  
  // Stage 2a, Tamatchi lower half, left foot forward
  lbpx  mx,  0x0                                                                   // 0x1150 (0x900)
  lbpx  mx,  0x0                                                                   // 0x1151 (0x900)
  lbpx  mx,  0x1                                                                   // 0x1152 (0x901)
  lbpx  mx,  0x7                                                                   // 0x1153 (0x907)
  lbpx  mx,  0x18                                                                  // 0x1154 (0x918)
  lbpx  mx,  0x20                                                                  // 0x1155 (0x920)
  lbpx  mx,  0x18                                                                  // 0x1156 (0x918)
  lbpx  mx,  0x8                                                                   // 0x1157 (0x908)
  lbpx  mx,  0x8                                                                   // 0x1158 (0x908)
  lbpx  mx,  0x8                                                                   // 0x1159 (0x908)
  lbpx  mx,  0x10                                                                  // 0x115A (0x910)
  lbpx  mx,  0x9                                                                   // 0x115B (0x909)
  lbpx  mx,  0x7                                                                   // 0x115C (0x907)
  lbpx  mx,  0x1                                                                   // 0x115D (0x901)
  lbpx  mx,  0x0                                                                   // 0x115E (0x900)
  retd  0x0                                                                        // 0x115F (0x100)
  
  // Stage 2a, Tamatchi lower half, feet transitioning
  lbpx  mx,  0x0                                                                   // 0x1160 (0x900)
  lbpx  mx,  0x0                                                                   // 0x1161 (0x900)
  lbpx  mx,  0x0                                                                   // 0x1162 (0x900)
  lbpx  mx,  0x3                                                                   // 0x1163 (0x903)
  lbpx  mx,  0x4                                                                   // 0x1164 (0x904)
  lbpx  mx,  0x18                                                                  // 0x1165 (0x918)
  lbpx  mx,  0x20                                                                  // 0x1166 (0x920)
  lbpx  mx,  0x18                                                                  // 0x1167 (0x918)
  lbpx  mx,  0x18                                                                  // 0x1168 (0x918)
  lbpx  mx,  0x28                                                                  // 0x1169 (0x928)
  lbpx  mx,  0x18                                                                  // 0x116A (0x918)
  lbpx  mx,  0x4                                                                   // 0x116B (0x904)
  lbpx  mx,  0x3                                                                   // 0x116C (0x903)
  lbpx  mx,  0x0                                                                   // 0x116D (0x900)
  lbpx  mx,  0x0                                                                   // 0x116E (0x900)
  retd  0x0                                                                        // 0x116F (0x100)
  
  // Stage 2a, Tamatchi lower half, right foot forward
  lbpx  mx,  0x0                                                                   // 0x1170 (0x900)
  lbpx  mx,  0x0                                                                   // 0x1171 (0x900)
  lbpx  mx,  0x0                                                                   // 0x1172 (0x900)
  lbpx  mx,  0x3                                                                   // 0x1173 (0x903)
  lbpx  mx,  0x1C                                                                  // 0x1174 (0x91C)
  lbpx  mx,  0x28                                                                  // 0x1175 (0x928)
  lbpx  mx,  0x18                                                                  // 0x1176 (0x918)
  lbpx  mx,  0x8                                                                   // 0x1177 (0x908)
  lbpx  mx,  0x8                                                                   // 0x1178 (0x908)
  lbpx  mx,  0x10                                                                  // 0x1179 (0x910)
  lbpx  mx,  0x20                                                                  // 0x117A (0x920)
  lbpx  mx,  0x3C                                                                  // 0x117B (0x93C)
  lbpx  mx,  0x3                                                                   // 0x117C (0x903)
  lbpx  mx,  0x0                                                                   // 0x117D (0x900)
  lbpx  mx,  0x0                                                                   // 0x117E (0x900)
  retd  0x0                                                                        // 0x117F (0x100)
  
  // Rectangular face with teeth
  // TODO: What is this?
  lbpx  mx,  0x0                                                                   // 0x1180 (0x900)
  lbpx  mx,  0x7E                                                                  // 0x1181 (0x97E)
  lbpx  mx,  0x81                                                                  // 0x1182 (0x981)
  lbpx  mx,  0x99                                                                  // 0x1183 (0x999)
  lbpx  mx,  0xAF                                                                  // 0x1184 (0x9AF)
  lbpx  mx,  0xB5                                                                  // 0x1185 (0x9B5)
  lbpx  mx,  0xAD                                                                  // 0x1186 (0x9AD)
  lbpx  mx,  0xB5                                                                  // 0x1187 (0x9B5)
  lbpx  mx,  0xAD                                                                  // 0x1188 (0x9AD)
  lbpx  mx,  0xB5                                                                  // 0x1189 (0x9B5)
  lbpx  mx,  0xAD                                                                  // 0x118A (0x9AD)
  lbpx  mx,  0xB5                                                                  // 0x118B (0x9B5)
  lbpx  mx,  0xAF                                                                  // 0x118C (0x9AF)
  lbpx  mx,  0x99                                                                  // 0x118D (0x999)
  lbpx  mx,  0x81                                                                  // 0x118E (0x981)
  retd  0x7E                                                                       // 0x118F (0x17E)
  
  // Possible base for teeth
  // TODO: What is this?
  lbpx  mx,  0x0                                                                   // 0x1190 (0x900)
  lbpx  mx,  0x3                                                                   // 0x1191 (0x903)
  lbpx  mx,  0x5                                                                   // 0x1192 (0x905)
  lbpx  mx,  0xC                                                                   // 0x1193 (0x90C)
  lbpx  mx,  0x10                                                                  // 0x1194 (0x910)
  lbpx  mx,  0x10                                                                  // 0x1195 (0x910)
  lbpx  mx,  0x20                                                                  // 0x1196 (0x920)
  lbpx  mx,  0x10                                                                  // 0x1197 (0x910)
  lbpx  mx,  0x10                                                                  // 0x1198 (0x910)
  lbpx  mx,  0x20                                                                  // 0x1199 (0x920)
  lbpx  mx,  0x10                                                                  // 0x119A (0x910)
  lbpx  mx,  0x10                                                                  // 0x119B (0x910)
  lbpx  mx,  0xC                                                                   // 0x119C (0x90C)
  lbpx  mx,  0x5                                                                   // 0x119D (0x905)
  lbpx  mx,  0x3                                                                   // 0x119E (0x903)
  retd  0x0                                                                        // 0x119F (0x100)
  
  // Stage 2b, KuchiTamatchi upper half, neutral
  lbpx  mx,  0x50                                                                  // 0x11A0 (0x950)
  lbpx  mx,  0xA8                                                                  // 0x11A1 (0x9A8)
  lbpx  mx,  0xA8                                                                  // 0x11A2 (0x9A8)
  lbpx  mx,  0xA8                                                                  // 0x11A3 (0x9A8)
  lbpx  mx,  0x4                                                                   // 0x11A4 (0x904)
  lbpx  mx,  0xA                                                                   // 0x11A5 (0x90A)
  lbpx  mx,  0x2                                                                   // 0x11A6 (0x902)
  lbpx  mx,  0x2                                                                   // 0x11A7 (0x902)
  lbpx  mx,  0x2                                                                   // 0x11A8 (0x902)
  lbpx  mx,  0xA                                                                   // 0x11A9 (0x90A)
  lbpx  mx,  0x4                                                                   // 0x11AA (0x904)
  lbpx  mx,  0x8                                                                   // 0x11AB (0x908)
  lbpx  mx,  0xF0                                                                  // 0x11AC (0x9F0)
  lbpx  mx,  0x0                                                                   // 0x11AD (0x900)
  lbpx  mx,  0x0                                                                   // 0x11AE (0x900)
  retd  0x0                                                                        // 0x11AF (0x100)
  
  // Stage 2b, KuchiTamatchi upper half, squished mouth
  lbpx  mx,  0x6C                                                                  // 0x11B0 (0x96C)
  lbpx  mx,  0x92                                                                  // 0x11B1 (0x992)
  lbpx  mx,  0x54                                                                  // 0x11B2 (0x954)
  lbpx  mx,  0xD4                                                                  // 0x11B3 (0x9D4)
  lbpx  mx,  0x2                                                                   // 0x11B4 (0x902)
  lbpx  mx,  0x6                                                                   // 0x11B5 (0x906)
  lbpx  mx,  0x2                                                                   // 0x11B6 (0x902)
  lbpx  mx,  0x2                                                                   // 0x11B7 (0x902)
  lbpx  mx,  0xA                                                                   // 0x11B8 (0x90A)
  lbpx  mx,  0x2                                                                   // 0x11B9 (0x902)
  lbpx  mx,  0x4                                                                   // 0x11BA (0x904)
  lbpx  mx,  0x8                                                                   // 0x11BB (0x908)
  lbpx  mx,  0xF0                                                                  // 0x11BC (0x9F0)
  lbpx  mx,  0x0                                                                   // 0x11BD (0x900)
  lbpx  mx,  0x0                                                                   // 0x11BE (0x900)
  retd  0x0                                                                        // 0x11BF (0x100)
  
  // Stage 2b, KuchiTamatchi upper half, open mouth
  lbpx  mx,  0x44                                                                  // 0x11C0 (0x944)
  lbpx  mx,  0xAA                                                                  // 0x11C1 (0x9AA)
  lbpx  mx,  0xAA                                                                  // 0x11C2 (0x9AA)
  lbpx  mx,  0xBA                                                                  // 0x11C3 (0x9BA)
  lbpx  mx,  0x2                                                                   // 0x11C4 (0x902)
  lbpx  mx,  0x2                                                                   // 0x11C5 (0x902)
  lbpx  mx,  0x6                                                                   // 0x11C6 (0x906)
  lbpx  mx,  0x2                                                                   // 0x11C7 (0x902)
  lbpx  mx,  0x2                                                                   // 0x11C8 (0x902)
  lbpx  mx,  0x22                                                                  // 0x11C9 (0x922)
  lbpx  mx,  0x4                                                                   // 0x11CA (0x904)
  lbpx  mx,  0x8                                                                   // 0x11CB (0x908)
  lbpx  mx,  0xF0                                                                  // 0x11CC (0x9F0)
  lbpx  mx,  0x0                                                                   // 0x11CD (0x900)
  lbpx  mx,  0x0                                                                   // 0x11CE (0x900)
  retd  0x0                                                                        // 0x11CF (0x100)
  
  // Stage 2b, KuchiTamatchi upper half, looking right, closed eyes
  lbpx  mx,  0x0                                                                   // 0x11D0 (0x900)
  lbpx  mx,  0x0                                                                   // 0x11D1 (0x900)
  lbpx  mx,  0x0                                                                   // 0x11D2 (0x900)
  lbpx  mx,  0xF0                                                                  // 0x11D3 (0x9F0)
  lbpx  mx,  0x8                                                                   // 0x11D4 (0x908)
  lbpx  mx,  0x4                                                                   // 0x11D5 (0x904)
  lbpx  mx,  0xA                                                                   // 0x11D6 (0x90A)
  lbpx  mx,  0xA                                                                   // 0x11D7 (0x90A)
  lbpx  mx,  0x2                                                                   // 0x11D8 (0x902)
  lbpx  mx,  0xA                                                                   // 0x11D9 (0x90A)
  lbpx  mx,  0xA                                                                   // 0x11DA (0x90A)
  lbpx  mx,  0x4                                                                   // 0x11DB (0x904)
  lbpx  mx,  0xA8                                                                  // 0x11DC (0x9A8)
  lbpx  mx,  0xA8                                                                  // 0x11DD (0x9A8)
  lbpx  mx,  0xA8                                                                  // 0x11DE (0x9A8)
  retd  0x50                                                                       // 0x11DF (0x150)

//
// Initializes 0xF** configuration
// Clears memory
// Returns
set_init_mem_and_int:
  ld    a,   0xF                                                                   // 0x11E0 (0xE0F)
  ld    xp,  a                                                                     // 0x11E1 (0xE80)
  // X is 0xF10 (clock timer interrupt mask)
  ld    x,   0x10                                                                  // 0x11E2 (0xB10)
  // Enable 1Hz interrupt
  ldpx  mx,  0x8                                                                   // 0x11E3 (0xE68)
  // Disable stopwatch interrupt
  ldpx  mx,  0x0                                                                   // 0x11E4 (0xE60)
  // Enable prog timer interrupt
  ldpx  mx,  0x1                                                                   // 0x11E5 (0xE61)
  // Disable serial interrupt
  ldpx  mx,  0x0                                                                   // 0x11E6 (0xE60)
  // Disable input K0 interupts
  ldpx  mx,  0x0                                                                   // 0x11E7 (0xE60)
  // Disable input K1 interrupts
  ldpx  mx,  0x0                                                                   // 0x11E8 (0xE60)
  // X is 0xF26
  ld    x,   0x26                                                                  // 0x11E9 (0xB26)
  // Set prog timer reload low nibble to 0x7
  lbpx  mx,  0x7                                                                   // 0x11EA (0x907)
  // X is 0xF54
  ld    x,   0x54                                                                  // 0x11EB (0xB54)
  // Disable buzzer, and output ports
  ldpx  mx,  0xF                                                                   // 0x11EC (0xE6F)
  // X is 0xF71
  ld    x,   0x71                                                                  // 0x11ED (0xB71)
  // Turn off all LCD pixels
  ldpx  mx,  0x8                                                                   // 0x11EE (0xE68)
  // Set LCD to medium intensity
  ldpx  mx,  0x8                                                                   // 0x11EF (0xE68)
  // X is 0xF76
  ld    x,   0x76                                                                  // 0x11F0 (0xB76)
  // Reset clock and watchdog timers
  ldpx  mx,  0x3                                                                   // 0x11F1 (0xE63)
  // Reset stopwatch timer
  ldpx  mx,  0x2                                                                   // 0x11F2 (0xE62)
  // Reset prog timer
  ldpx  mx,  0x2                                                                   // 0x11F3 (0xE62)
  // Set prog timer to 256Hz
  ldpx  mx,  0x2                                                                   // 0x11F4 (0xE62)
  pset  0x2                                                                        // 0x11F5 (0xE42)
  jp    set_init_mem_and_int_cont_mem_clear                                        // 0x11F6 (0x44)
  nop7                                                                             // 0x11F7 (0xFFF)
  nop7                                                                             // 0x11F8 (0xFFF)
  nop7                                                                             // 0x11F9 (0xFFF)
  nop7                                                                             // 0x11FA (0xFFF)
  nop7                                                                             // 0x11FB (0xFFF)
  nop7                                                                             // 0x11FC (0xFFF)
  nop7                                                                             // 0x11FD (0xFFF)
  nop7                                                                             // 0x11FE (0xFFF)
  nop7                                                                             // 0x11FF (0xFFF)

//
// Continuation of set_init_mem_and_int
// Sets memory initial values
// Starts timers and clears factors
//
set_init_mem_and_int_cont_set_mem:
  ld    a,   0x0                                                                   // 0x1200 (0xE00)
  ld    xp,  a                                                                     // 0x1201 (0xE80)
  // X is 0x024
  ld    x,   0x24                                                                  // 0x1202 (0xB24)
  lbpx  mx,  0x0                                                                   // 0x1203 (0x900)
  ld    x,   0x14                                                                  // 0x1204 (0xB14)
  lbpx  mx,  0x20                                                                  // 0x1205 (0x920)
  ld    x,   0x32                                                                  // 0x1206 (0xB32)
  lbpx  mx,  0x0                                                                   // 0x1207 (0x900)
  ld    x,   0x36                                                                  // 0x1208 (0xB36)
  lbpx  mx,  0x7D                                                                  // 0x1209 (0x97D)
  ld    x,   0x58                                                                  // 0x120A (0xB58)
  lbpx  mx,  0xFF                                                                  // 0x120B (0x9FF)
  ld    x,   0x7B                                                                  // 0x120C (0xB7B)
  ldpx  mx,  0xF                                                                   // 0x120D (0xE6F)
  ld    x,   0x7D                                                                  // 0x120E (0xB7D)
  ld    mx,  0xF                                                                   // 0x120F (0xE2F)
  ld    x,   0x3C                                                                  // 0x1210 (0xB3C)
  ld    mx,  0x0                                                                   // 0x1211 (0xE20)
  ld    x,   0x74                                                                  // 0x1212 (0xB74)
  ldpx  mx,  0x0                                                                   // 0x1213 (0xE60)
  ld    x,   0x7C                                                                  // 0x1214 (0xB7C)
  ld    mx,  0x5                                                                   // 0x1215 (0xE25)
  ld    a,   0xF                                                                   // 0x1216 (0xE0F)
  ld    xp,  a                                                                     // 0x1217 (0xE80)
  // X is 0xF71
  ld    x,   0x71                                                                  // 0x1218 (0xB71)
  // Allow LCD pixels to display normally
  ld    mx,  0x0                                                                   // 0x1219 (0xE20)
  // X is 0xF78
  ld    x,   0x78                                                                  // 0x121A (0xB78)
  // Start prog timer
  ld    mx,  0x1                                                                   // 0x121B (0xE21)
  // X is 0xF00
  ld    x,   0x0                                                                   // 0x121C (0xB00)
  // Clear clock factors
  ldpx  a,   mx                                                                    // 0x121D (0xEE2)
  // Clear stopwatch factors
  ldpx  a,   mx                                                                    // 0x121E (0xEE2)
  // Clear prog timer factor
  ld    a,   mx                                                                    // 0x121F (0xEC2)
  pset  0x2                                                                        // 0x1220 (0xE42)
  jp    set_init_mem_and_int_bank0_ret                                             // 0x1221 (0x55)

//
// Copies 6 nibbles from MX to MY, incrementing both
// Returns
copy_6_mx_my:
  ldpx  my,  mx                                                                    // 0x1222 (0xEEE)
  ldpy  a,   a                                                                     // 0x1223 (0xEF0)
  ldpx  my,  mx                                                                    // 0x1224 (0xEEE)
  ldpy  a,   a                                                                     // 0x1225 (0xEF0)
  ldpx  my,  mx                                                                    // 0x1226 (0xEEE)
  ldpy  a,   a                                                                     // 0x1227 (0xEF0)
  ldpx  my,  mx                                                                    // 0x1228 (0xEEE)
  ldpy  a,   a                                                                     // 0x1229 (0xEF0)
  ldpx  my,  mx                                                                    // 0x122A (0xEEE)
  ldpy  a,   a                                                                     // 0x122B (0xEF0)
  ldpx  my,  mx                                                                    // 0x122C (0xEEE)
  pset  0x2                                                                        // 0x122D (0xE42)
  jp    copy_6_mx_my_bank0_ret                                                     // 0x122E (0x29)
  nop7                                                                             // 0x122F (0xFFF)
  
  // Stage 3a, Mametchi upper half, turned left
  lbpx  mx,  0x0                                                                   // 0x1230 (0x900)
  lbpx  mx,  0x0                                                                   // 0x1231 (0x900)
  lbpx  mx,  0x60                                                                  // 0x1232 (0x960)
  lbpx  mx,  0x90                                                                  // 0x1233 (0x990)
  lbpx  mx,  0xE                                                                   // 0x1234 (0x90E)
  lbpx  mx,  0x57                                                                  // 0x1235 (0x957)
  lbpx  mx,  0x46                                                                  // 0x1236 (0x946)
  lbpx  mx,  0x4                                                                   // 0x1237 (0x904)
  lbpx  mx,  0x4                                                                   // 0x1238 (0x904)
  lbpx  mx,  0x14                                                                  // 0x1239 (0x914)
  lbpx  mx,  0x6                                                                   // 0x123A (0x906)
  lbpx  mx,  0xF                                                                   // 0x123B (0x90F)
  lbpx  mx,  0x1E                                                                  // 0x123C (0x91E)
  lbpx  mx,  0xF0                                                                  // 0x123D (0x9F0)
  lbpx  mx,  0x0                                                                   // 0x123E (0x900)
  retd  0x0                                                                        // 0x123F (0x100)
  
  // Stage 3a, Mametchi lower half, turned left
  lbpx  mx,  0x0                                                                   // 0x1240 (0x900)
  lbpx  mx,  0x0                                                                   // 0x1241 (0x900)
  lbpx  mx,  0x0                                                                   // 0x1242 (0x900)
  lbpx  mx,  0x7                                                                   // 0x1243 (0x907)
  lbpx  mx,  0x8                                                                   // 0x1244 (0x908)
  lbpx  mx,  0x30                                                                  // 0x1245 (0x930)
  lbpx  mx,  0x40                                                                  // 0x1246 (0x940)
  lbpx  mx,  0x30                                                                  // 0x1247 (0x930)
  lbpx  mx,  0x13                                                                  // 0x1248 (0x913)
  lbpx  mx,  0x34                                                                  // 0x1249 (0x934)
  lbpx  mx,  0x43                                                                  // 0x124A (0x943)
  lbpx  mx,  0x30                                                                  // 0x124B (0x930)
  lbpx  mx,  0x8                                                                   // 0x124C (0x908)
  lbpx  mx,  0x7                                                                   // 0x124D (0x907)
  lbpx  mx,  0x0                                                                   // 0x124E (0x900)
  retd  0x0                                                                        // 0x124F (0x100)
  
  // Stage 3a, Mametchi upper half, front facing
  lbpx  mx,  0x0                                                                   // 0x1250 (0x900)
  lbpx  mx,  0x60                                                                  // 0x1251 (0x960)
  lbpx  mx,  0x9E                                                                  // 0x1252 (0x99E)
  lbpx  mx,  0x7                                                                   // 0x1253 (0x907)
  lbpx  mx,  0x7                                                                   // 0x1254 (0x907)
  lbpx  mx,  0x16                                                                  // 0x1255 (0x916)
  lbpx  mx,  0x44                                                                  // 0x1256 (0x944)
  lbpx  mx,  0x44                                                                  // 0x1257 (0x944)
  lbpx  mx,  0x44                                                                  // 0x1258 (0x944)
  lbpx  mx,  0x16                                                                  // 0x1259 (0x916)
  lbpx  mx,  0x7                                                                   // 0x125A (0x907)
  lbpx  mx,  0x7                                                                   // 0x125B (0x907)
  lbpx  mx,  0x9E                                                                  // 0x125C (0x99E)
  lbpx  mx,  0x60                                                                  // 0x125D (0x960)
  lbpx  mx,  0x0                                                                   // 0x125E (0x900)
  retd  0x0                                                                        // 0x125F (0x100)
  
  // Stage 3a, Mametchi lower half, right leg forward
  lbpx  mx,  0x0                                                                   // 0x1260 (0x900)
  lbpx  mx,  0x0                                                                   // 0x1261 (0x900)
  lbpx  mx,  0x7                                                                   // 0x1262 (0x907)
  lbpx  mx,  0xA                                                                   // 0x1263 (0x90A)
  lbpx  mx,  0x13                                                                  // 0x1264 (0x913)
  lbpx  mx,  0x20                                                                  // 0x1265 (0x920)
  lbpx  mx,  0x10                                                                  // 0x1266 (0x910)
  lbpx  mx,  0x10                                                                  // 0x1267 (0x910)
  lbpx  mx,  0x30                                                                  // 0x1268 (0x930)
  lbpx  mx,  0x40                                                                  // 0x1269 (0x940)
  lbpx  mx,  0x31                                                                  // 0x126A (0x931)
  lbpx  mx,  0xA                                                                   // 0x126B (0x90A)
  lbpx  mx,  0x6                                                                   // 0x126C (0x906)
  lbpx  mx,  0x1                                                                   // 0x126D (0x901)
  lbpx  mx,  0x0                                                                   // 0x126E (0x900)
  retd  0x0                                                                        // 0x126F (0x100)
  
  // Stage 3a, Mametchi upper half, mouth open, eating
  lbpx  mx,  0x0                                                                   // 0x1270 (0x900)
  lbpx  mx,  0x0                                                                   // 0x1271 (0x900)
  lbpx  mx,  0x70                                                                  // 0x1272 (0x970)
  lbpx  mx,  0x88                                                                  // 0x1273 (0x988)
  lbpx  mx,  0x4                                                                   // 0x1274 (0x904)
  lbpx  mx,  0x74                                                                  // 0x1275 (0x974)
  lbpx  mx,  0x72                                                                  // 0x1276 (0x972)
  lbpx  mx,  0x73                                                                  // 0x1277 (0x973)
  lbpx  mx,  0x77                                                                  // 0x1278 (0x977)
  lbpx  mx,  0x6                                                                   // 0x1279 (0x906)
  lbpx  mx,  0xC                                                                   // 0x127A (0x90C)
  lbpx  mx,  0x2C                                                                  // 0x127B (0x92C)
  lbpx  mx,  0x1C                                                                  // 0x127C (0x91C)
  lbpx  mx,  0xFC                                                                  // 0x127D (0x9FC)
  lbpx  mx,  0x18                                                                  // 0x127E (0x918)
  retd  0x0                                                                        // 0x127F (0x100)
  
  // Stage 3a, Mametchi lower half, extended back for eating
  lbpx  mx,  0x0                                                                   // 0x1280 (0x900)
  lbpx  mx,  0x0                                                                   // 0x1281 (0x900)
  lbpx  mx,  0x0                                                                   // 0x1282 (0x900)
  lbpx  mx,  0xF                                                                   // 0x1283 (0x90F)
  lbpx  mx,  0x30                                                                  // 0x1284 (0x930)
  lbpx  mx,  0x40                                                                  // 0x1285 (0x940)
  lbpx  mx,  0x30                                                                  // 0x1286 (0x930)
  lbpx  mx,  0x30                                                                  // 0x1287 (0x930)
  lbpx  mx,  0x41                                                                  // 0x1288 (0x941)
  lbpx  mx,  0x32                                                                  // 0x1289 (0x932)
  lbpx  mx,  0x11                                                                  // 0x128A (0x911)
  lbpx  mx,  0x10                                                                  // 0x128B (0x910)
  lbpx  mx,  0x8                                                                   // 0x128C (0x908)
  lbpx  mx,  0x7                                                                   // 0x128D (0x907)
  lbpx  mx,  0x0                                                                   // 0x128E (0x900)
  retd  0x0                                                                        // 0x128F (0x100)
  
  // Stage 3a, Mametchi upper half, sleeping
  lbpx  mx,  0x0                                                                   // 0x1290 (0x900)
  lbpx  mx,  0x60                                                                  // 0x1291 (0x960)
  lbpx  mx,  0x9E                                                                  // 0x1292 (0x99E)
  lbpx  mx,  0xF                                                                   // 0x1293 (0x90F)
  lbpx  mx,  0x17                                                                  // 0x1294 (0x917)
  lbpx  mx,  0x16                                                                  // 0x1295 (0x916)
  lbpx  mx,  0x4                                                                   // 0x1296 (0x904)
  lbpx  mx,  0x44                                                                  // 0x1297 (0x944)
  lbpx  mx,  0x4                                                                   // 0x1298 (0x904)
  lbpx  mx,  0x16                                                                  // 0x1299 (0x916)
  lbpx  mx,  0x17                                                                  // 0x129A (0x917)
  lbpx  mx,  0xF                                                                   // 0x129B (0x90F)
  lbpx  mx,  0x9E                                                                  // 0x129C (0x99E)
  lbpx  mx,  0x60                                                                  // 0x129D (0x960)
  lbpx  mx,  0x0                                                                   // 0x129E (0x900)
  retd  0x0                                                                        // 0x129F (0x100)
  
  // Stage 3b, Ginjirotchi upper half, turned left
  lbpx  mx,  0x0                                                                   // 0x12A0 (0x900)
  lbpx  mx,  0x60                                                                  // 0x12A1 (0x960)
  lbpx  mx,  0xD0                                                                  // 0x12A2 (0x9D0)
  lbpx  mx,  0x58                                                                  // 0x12A3 (0x958)
  lbpx  mx,  0x44                                                                  // 0x12A4 (0x944)
  lbpx  mx,  0x4A                                                                  // 0x12A5 (0x94A)
  lbpx  mx,  0x42                                                                  // 0x12A6 (0x942)
  lbpx  mx,  0x46                                                                  // 0x12A7 (0x946)
  lbpx  mx,  0x42                                                                  // 0x12A8 (0x942)
  lbpx  mx,  0x2A                                                                  // 0x12A9 (0x92A)
  lbpx  mx,  0x6                                                                   // 0x12AA (0x906)
  lbpx  mx,  0x1C                                                                  // 0x12AB (0x91C)
  lbpx  mx,  0xF8                                                                  // 0x12AC (0x9F8)
  lbpx  mx,  0xF0                                                                  // 0x12AD (0x9F0)
  lbpx  mx,  0x0                                                                   // 0x12AE (0x900)
  retd  0x0                                                                        // 0x12AF (0x100)
  
  // Stage 3b, Ginjirotchi upper half, front facing
  lbpx  mx,  0x0                                                                   // 0x12B0 (0x900)
  lbpx  mx,  0x0                                                                   // 0x12B1 (0x900)
  lbpx  mx,  0x0                                                                   // 0x12B2 (0x900)
  lbpx  mx,  0xF8                                                                  // 0x12B3 (0x9F8)
  lbpx  mx,  0x4                                                                   // 0x12B4 (0x904)
  lbpx  mx,  0x2A                                                                  // 0x12B5 (0x92A)
  lbpx  mx,  0x42                                                                  // 0x12B6 (0x942)
  lbpx  mx,  0x46                                                                  // 0x12B7 (0x946)
  lbpx  mx,  0x46                                                                  // 0x12B8 (0x946)
  lbpx  mx,  0x46                                                                  // 0x12B9 (0x946)
  lbpx  mx,  0x42                                                                  // 0x12BA (0x942)
  lbpx  mx,  0x2A                                                                  // 0x12BB (0x92A)
  lbpx  mx,  0x4                                                                   // 0x12BC (0x904)
  lbpx  mx,  0xF8                                                                  // 0x12BD (0x9F8)
  lbpx  mx,  0x0                                                                   // 0x12BE (0x900)
  retd  0x0                                                                        // 0x12BF (0x100)
  
  // Stage 3b, Ginjirotchi upper half, back facing?
  lbpx  mx,  0x0                                                                   // 0x12C0 (0x900)
  lbpx  mx,  0x0                                                                   // 0x12C1 (0x900)
  lbpx  mx,  0xF8                                                                  // 0x12C2 (0x9F8)
  lbpx  mx,  0x4                                                                   // 0x12C3 (0x904)
  lbpx  mx,  0xE                                                                   // 0x12C4 (0x90E)
  lbpx  mx,  0x1E                                                                  // 0x12C5 (0x91E)
  lbpx  mx,  0x3E                                                                  // 0x12C6 (0x93E)
  lbpx  mx,  0x7E                                                                  // 0x12C7 (0x97E)
  lbpx  mx,  0x7E                                                                  // 0x12C8 (0x97E)
  lbpx  mx,  0x3E                                                                  // 0x12C9 (0x93E)
  lbpx  mx,  0x1E                                                                  // 0x12CA (0x91E)
  lbpx  mx,  0x4                                                                   // 0x12CB (0x904)
  lbpx  mx,  0xF8                                                                  // 0x12CC (0x9F8)
  lbpx  mx,  0x0                                                                   // 0x12CD (0x900)
  lbpx  mx,  0x0                                                                   // 0x12CE (0x900)
  retd  0x0                                                                        // 0x12CF (0x100)
  
  // Stage 3b, Ginjirotchi bottom half
  lbpx  mx,  0x0                                                                   // 0x12D0 (0x900)
  lbpx  mx,  0x0                                                                   // 0x12D1 (0x900)
  lbpx  mx,  0x7                                                                   // 0x12D2 (0x907)
  lbpx  mx,  0x8                                                                   // 0x12D3 (0x908)
  lbpx  mx,  0x10                                                                  // 0x12D4 (0x910)
  lbpx  mx,  0x20                                                                  // 0x12D5 (0x920)
  lbpx  mx,  0x16                                                                  // 0x12D6 (0x916)
  lbpx  mx,  0x14                                                                  // 0x12D7 (0x914)
  lbpx  mx,  0x34                                                                  // 0x12D8 (0x934)
  lbpx  mx,  0x42                                                                  // 0x12D9 (0x942)
  lbpx  mx,  0x30                                                                  // 0x12DA (0x930)
  lbpx  mx,  0x8                                                                   // 0x12DB (0x908)
  lbpx  mx,  0x6                                                                   // 0x12DC (0x906)
  lbpx  mx,  0x1                                                                   // 0x12DD (0x901)
  lbpx  mx,  0x0                                                                   // 0x12DE (0x900)
  retd  0x0                                                                        // 0x12DF (0x100)
  
  // Stage 3b, Ginjirotchi upper half, open mouth, eating
  lbpx  mx,  0x30                                                                  // 0x12E0 (0x930)
  lbpx  mx,  0x28                                                                  // 0x12E1 (0x928)
  lbpx  mx,  0xA8                                                                  // 0x12E2 (0x9A8)
  lbpx  mx,  0xA8                                                                  // 0x12E3 (0x9A8)
  lbpx  mx,  0xA4                                                                  // 0x12E4 (0x9A4)
  lbpx  mx,  0xA4                                                                  // 0x12E5 (0x9A4)
  lbpx  mx,  0x6C                                                                  // 0x12E6 (0x96C)
  lbpx  mx,  0x4                                                                   // 0x12E7 (0x904)
  lbpx  mx,  0x4                                                                   // 0x12E8 (0x904)
  lbpx  mx,  0x4                                                                   // 0x12E9 (0x904)
  lbpx  mx,  0x2C                                                                  // 0x12EA (0x92C)
  lbpx  mx,  0x1C                                                                  // 0x12EB (0x91C)
  lbpx  mx,  0xF8                                                                  // 0x12EC (0x9F8)
  lbpx  mx,  0xF0                                                                  // 0x12ED (0x9F0)
  lbpx  mx,  0x0                                                                   // 0x12EE (0x900)
  retd  0x0                                                                        // 0x12EF (0x100)
  
  // Stage 3b, Ginjirotchi upper half, right facing, sleeping?
  lbpx  mx,  0x0                                                                   // 0x12F0 (0x900)
  lbpx  mx,  0x0                                                                   // 0x12F1 (0x900)
  lbpx  mx,  0xF0                                                                  // 0x12F2 (0x9F0)
  lbpx  mx,  0xF8                                                                  // 0x12F3 (0x9F8)
  lbpx  mx,  0x1C                                                                  // 0x12F4 (0x91C)
  lbpx  mx,  0xE                                                                   // 0x12F5 (0x90E)
  lbpx  mx,  0xA                                                                   // 0x12F6 (0x90A)
  lbpx  mx,  0x2                                                                   // 0x12F7 (0x902)
  lbpx  mx,  0x46                                                                  // 0x12F8 (0x946)
  lbpx  mx,  0x42                                                                  // 0x12F9 (0x942)
  lbpx  mx,  0x4A                                                                  // 0x12FA (0x94A)
  lbpx  mx,  0x4C                                                                  // 0x12FB (0x94C)
  lbpx  mx,  0x58                                                                  // 0x12FC (0x958)
  lbpx  mx,  0xD0                                                                  // 0x12FD (0x9D0)
  lbpx  mx,  0x60                                                                  // 0x12FE (0x960)
  retd  0x0                                                                        // 0x12FF (0x100)
  
  // Stage 3c, Maskutchi upper half, left facing, big eyes
  lbpx  mx,  0x0                                                                   // 0x1300 (0x900)
  lbpx  mx,  0xC0                                                                  // 0x1301 (0x9C0)
  lbpx  mx,  0xF8                                                                  // 0x1302 (0x9F8)
  lbpx  mx,  0xAC                                                                  // 0x1303 (0x9AC)
  lbpx  mx,  0x8E                                                                  // 0x1304 (0x98E)
  lbpx  mx,  0x7E                                                                  // 0x1305 (0x97E)
  lbpx  mx,  0x1E                                                                  // 0x1306 (0x91E)
  lbpx  mx,  0x1E                                                                  // 0x1307 (0x91E)
  lbpx  mx,  0x1F                                                                  // 0x1308 (0x91F)
  lbpx  mx,  0x3F                                                                  // 0x1309 (0x93F)
  lbpx  mx,  0x3F                                                                  // 0x130A (0x93F)
  lbpx  mx,  0x3F                                                                  // 0x130B (0x93F)
  lbpx  mx,  0x7C                                                                  // 0x130C (0x97C)
  lbpx  mx,  0xF8                                                                  // 0x130D (0x9F8)
  lbpx  mx,  0x0                                                                   // 0x130E (0x900)
  retd  0x0                                                                        // 0x130F (0x100)
  
  // Stage 3c, Maskutchi lower half, leaning right
  lbpx  mx,  0x0                                                                   // 0x1310 (0x900)
  lbpx  mx,  0x40                                                                  // 0x1311 (0x940)
  lbpx  mx,  0x60                                                                  // 0x1312 (0x960)
  lbpx  mx,  0x53                                                                  // 0x1313 (0x953)
  lbpx  mx,  0x14                                                                  // 0x1314 (0x914)
  lbpx  mx,  0x8                                                                   // 0x1315 (0x908)
  lbpx  mx,  0x10                                                                  // 0x1316 (0x910)
  lbpx  mx,  0x10                                                                  // 0x1317 (0x910)
  lbpx  mx,  0x10                                                                  // 0x1318 (0x910)
  lbpx  mx,  0x10                                                                  // 0x1319 (0x910)
  lbpx  mx,  0x10                                                                  // 0x131A (0x910)
  lbpx  mx,  0x10                                                                  // 0x131B (0x910)
  lbpx  mx,  0x8                                                                   // 0x131C (0x908)
  lbpx  mx,  0x44                                                                  // 0x131D (0x944)
  lbpx  mx,  0x6B                                                                  // 0x131E (0x96B)
  retd  0x58                                                                       // 0x131F (0x158)
  
  // Stage 3c, Maskutchi lower half, leaning left
  lbpx  mx,  0x0                                                                   // 0x1320 (0x900)
  lbpx  mx,  0x0                                                                   // 0x1321 (0x900)
  lbpx  mx,  0xD                                                                   // 0x1322 (0x90D)
  lbpx  mx,  0x52                                                                  // 0x1323 (0x952)
  lbpx  mx,  0x62                                                                  // 0x1324 (0x962)
  lbpx  mx,  0x44                                                                  // 0x1325 (0x944)
  lbpx  mx,  0x4                                                                   // 0x1326 (0x904)
  lbpx  mx,  0x4                                                                   // 0x1327 (0x904)
  lbpx  mx,  0x4                                                                   // 0x1328 (0x904)
  lbpx  mx,  0x4                                                                   // 0x1329 (0x904)
  lbpx  mx,  0x4                                                                   // 0x132A (0x904)
  lbpx  mx,  0x2                                                                   // 0x132B (0x902)
  lbpx  mx,  0x4E                                                                  // 0x132C (0x94E)
  lbpx  mx,  0x71                                                                  // 0x132D (0x971)
  lbpx  mx,  0x40                                                                  // 0x132E (0x940)
  retd  0x0                                                                        // 0x132F (0x100)
  
  // Tombstone top, WWW symbol
  // TODO: What is this used for?
  lbpx  mx,  0x0                                                                   // 0x1330 (0x900)
  lbpx  mx,  0x0                                                                   // 0x1331 (0x900)
  lbpx  mx,  0xFC                                                                  // 0x1332 (0x9FC)
  lbpx  mx,  0x2                                                                   // 0x1333 (0x902)
  lbpx  mx,  0x79                                                                  // 0x1334 (0x979)
  lbpx  mx,  0xB5                                                                  // 0x1335 (0x9B5)
  lbpx  mx,  0xFD                                                                  // 0x1336 (0x9FD)
  lbpx  mx,  0xB5                                                                  // 0x1337 (0x9B5)
  lbpx  mx,  0xB5                                                                  // 0x1338 (0x9B5)
  lbpx  mx,  0xFD                                                                  // 0x1339 (0x9FD)
  lbpx  mx,  0xB5                                                                  // 0x133A (0x9B5)
  lbpx  mx,  0x79                                                                  // 0x133B (0x979)
  lbpx  mx,  0x2                                                                   // 0x133C (0x902)
  lbpx  mx,  0xFC                                                                  // 0x133D (0x9FC)
  lbpx  mx,  0x0                                                                   // 0x133E (0x900)
  retd  0x0                                                                        // 0x133F (0x100)
  
  // Tombstone top, line
  lbpx  mx,  0x0                                                                   // 0x1340 (0x900)
  lbpx  mx,  0x0                                                                   // 0x1341 (0x900)
  lbpx  mx,  0xFC                                                                  // 0x1342 (0x9FC)
  lbpx  mx,  0x2                                                                   // 0x1343 (0x902)
  lbpx  mx,  0x11                                                                  // 0x1344 (0x911)
  lbpx  mx,  0x11                                                                  // 0x1345 (0x911)
  lbpx  mx,  0x11                                                                  // 0x1346 (0x911)
  lbpx  mx,  0x11                                                                  // 0x1347 (0x911)
  lbpx  mx,  0x11                                                                  // 0x1348 (0x911)
  lbpx  mx,  0x11                                                                  // 0x1349 (0x911)
  lbpx  mx,  0x11                                                                  // 0x134A (0x911)
  lbpx  mx,  0x11                                                                  // 0x134B (0x911)
  lbpx  mx,  0x2                                                                   // 0x134C (0x902)
  lbpx  mx,  0xFC                                                                  // 0x134D (0x9FC)
  lbpx  mx,  0x0                                                                   // 0x134E (0x900)
  retd  0x0                                                                        // 0x134F (0x100)
  
  // Stage 3c, Maskutchi upper half, front facing, small eyes
  lbpx  mx,  0x0                                                                   // 0x1350 (0x900)
  lbpx  mx,  0x0                                                                   // 0x1351 (0x900)
  lbpx  mx,  0xF8                                                                  // 0x1352 (0x9F8)
  lbpx  mx,  0x1C                                                                  // 0x1353 (0x91C)
  lbpx  mx,  0x7F                                                                  // 0x1354 (0x97F)
  lbpx  mx,  0xDF                                                                  // 0x1355 (0x9DF)
  lbpx  mx,  0xDE                                                                  // 0x1356 (0x9DE)
  lbpx  mx,  0xFE                                                                  // 0x1357 (0x9FE)
  lbpx  mx,  0xFE                                                                  // 0x1358 (0x9FE)
  lbpx  mx,  0xDE                                                                  // 0x1359 (0x9DE)
  lbpx  mx,  0xDF                                                                  // 0x135A (0x9DF)
  lbpx  mx,  0x7F                                                                  // 0x135B (0x97F)
  lbpx  mx,  0x1C                                                                  // 0x135C (0x91C)
  lbpx  mx,  0xF8                                                                  // 0x135D (0x9F8)
  lbpx  mx,  0x0                                                                   // 0x135E (0x900)
  retd  0x0                                                                        // 0x135F (0x100)
  
  // Stage 3c, Maskutchi upper half, front facing, big eyes pointing right
  lbpx  mx,  0x0                                                                   // 0x1360 (0x900)
  lbpx  mx,  0x0                                                                   // 0x1361 (0x900)
  lbpx  mx,  0xF8                                                                  // 0x1362 (0x9F8)
  lbpx  mx,  0x1C                                                                  // 0x1363 (0x91C)
  lbpx  mx,  0x7F                                                                  // 0x1364 (0x97F)
  lbpx  mx,  0x8F                                                                  // 0x1365 (0x98F)
  lbpx  mx,  0xAE                                                                  // 0x1366 (0x9AE)
  lbpx  mx,  0xFE                                                                  // 0x1367 (0x9FE)
  lbpx  mx,  0xFE                                                                  // 0x1368 (0x9FE)
  lbpx  mx,  0x8E                                                                  // 0x1369 (0x98E)
  lbpx  mx,  0xAF                                                                  // 0x136A (0x9AF)
  lbpx  mx,  0x7F                                                                  // 0x136B (0x97F)
  lbpx  mx,  0x1C                                                                  // 0x136C (0x91C)
  lbpx  mx,  0xF8                                                                  // 0x136D (0x9F8)
  lbpx  mx,  0x0                                                                   // 0x136E (0x900)
  retd  0x0                                                                        // 0x136F (0x100)
  
  // Stage 3c, Maskutchi upper half, left facing, small eyes
  lbpx  mx,  0x0                                                                   // 0x1370 (0x900)
  lbpx  mx,  0xC0                                                                  // 0x1371 (0x9C0)
  lbpx  mx,  0xF8                                                                  // 0x1372 (0x9F8)
  lbpx  mx,  0xDC                                                                  // 0x1373 (0x9DC)
  lbpx  mx,  0xDE                                                                  // 0x1374 (0x9DE)
  lbpx  mx,  0x7E                                                                  // 0x1375 (0x97E)
  lbpx  mx,  0x1E                                                                  // 0x1376 (0x91E)
  lbpx  mx,  0x1E                                                                  // 0x1377 (0x91E)
  lbpx  mx,  0x1F                                                                  // 0x1378 (0x91F)
  lbpx  mx,  0x3F                                                                  // 0x1379 (0x93F)
  lbpx  mx,  0x3F                                                                  // 0x137A (0x93F)
  lbpx  mx,  0x3F                                                                  // 0x137B (0x93F)
  lbpx  mx,  0x7C                                                                  // 0x137C (0x97C)
  lbpx  mx,  0xF8                                                                  // 0x137D (0x9F8)
  lbpx  mx,  0x0                                                                   // 0x137E (0x900)
  retd  0x0                                                                        // 0x137F (0x100)
  
  // Stage 3d, Kuchipatchi upper half, left facing
  lbpx  mx,  0x0                                                                   // 0x1380 (0x900)
  lbpx  mx,  0xF8                                                                  // 0x1381 (0x9F8)
  lbpx  mx,  0xA8                                                                  // 0x1382 (0x9A8)
  lbpx  mx,  0xAC                                                                  // 0x1383 (0x9AC)
  lbpx  mx,  0xAA                                                                  // 0x1384 (0x9AA)
  lbpx  mx,  0xA9                                                                  // 0x1385 (0x9A9)
  lbpx  mx,  0xED                                                                  // 0x1386 (0x9ED)
  lbpx  mx,  0x39                                                                  // 0x1387 (0x939)
  lbpx  mx,  0x1                                                                   // 0x1388 (0x901)
  lbpx  mx,  0x5                                                                   // 0x1389 (0x905)
  lbpx  mx,  0x3                                                                   // 0x138A (0x903)
  lbpx  mx,  0x7                                                                   // 0x138B (0x907)
  lbpx  mx,  0xE                                                                   // 0x138C (0x90E)
  lbpx  mx,  0xFC                                                                  // 0x138D (0x9FC)
  lbpx  mx,  0x0                                                                   // 0x138E (0x900)
  retd  0x0                                                                        // 0x138F (0x100)
  
  // Stage 3d, Kuchipatchi upper half, open mouth, happy
  lbpx  mx,  0xE7                                                                  // 0x1390 (0x9E7)
  lbpx  mx,  0xA5                                                                  // 0x1391 (0x9A5)
  lbpx  mx,  0xBD                                                                  // 0x1392 (0x9BD)
  lbpx  mx,  0xBD                                                                  // 0x1393 (0x9BD)
  lbpx  mx,  0xBD                                                                  // 0x1394 (0x9BD)
  lbpx  mx,  0xFD                                                                  // 0x1395 (0x9FD)
  lbpx  mx,  0x7                                                                   // 0x1396 (0x907)
  lbpx  mx,  0x1                                                                   // 0x1397 (0x901)
  lbpx  mx,  0x11                                                                  // 0x1398 (0x911)
  lbpx  mx,  0x9                                                                   // 0x1399 (0x909)
  lbpx  mx,  0x11                                                                  // 0x139A (0x911)
  lbpx  mx,  0x2                                                                   // 0x139B (0x902)
  lbpx  mx,  0xFC                                                                  // 0x139C (0x9FC)
  lbpx  mx,  0x0                                                                   // 0x139D (0x900)
  lbpx  mx,  0x0                                                                   // 0x139E (0x900)
  retd  0x0                                                                        // 0x139F (0x100)
  
  // Stage 3d, Kuchipatchi upper half, sleeping?
  lbpx  mx,  0x0                                                                   // 0x13A0 (0x900)
  lbpx  mx,  0xF8                                                                  // 0x13A1 (0x9F8)
  lbpx  mx,  0xA8                                                                  // 0x13A2 (0x9A8)
  lbpx  mx,  0xAC                                                                  // 0x13A3 (0x9AC)
  lbpx  mx,  0xAA                                                                  // 0x13A4 (0x9AA)
  lbpx  mx,  0xAD                                                                  // 0x13A5 (0x9AD)
  lbpx  mx,  0xED                                                                  // 0x13A6 (0x9ED)
  lbpx  mx,  0x39                                                                  // 0x13A7 (0x939)
  lbpx  mx,  0x1                                                                   // 0x13A8 (0x901)
  lbpx  mx,  0x9                                                                   // 0x13A9 (0x909)
  lbpx  mx,  0xB                                                                   // 0x13AA (0x90B)
  lbpx  mx,  0x7                                                                   // 0x13AB (0x907)
  lbpx  mx,  0xE                                                                   // 0x13AC (0x90E)
  lbpx  mx,  0xFC                                                                  // 0x13AD (0x9FC)
  lbpx  mx,  0x0                                                                   // 0x13AE (0x900)
  retd  0x0                                                                        // 0x13AF (0x100)
  
  // Stage 3d, Kuchipatchi upper half, front facing
  lbpx  mx,  0x0                                                                   // 0x13B0 (0x900)
  lbpx  mx,  0x0                                                                   // 0x13B1 (0x900)
  lbpx  mx,  0xF8                                                                  // 0x13B2 (0x9F8)
  lbpx  mx,  0x4                                                                   // 0x13B3 (0x904)
  lbpx  mx,  0xA                                                                   // 0x13B4 (0x90A)
  lbpx  mx,  0x2                                                                   // 0x13B5 (0x902)
  lbpx  mx,  0xA2                                                                  // 0x13B6 (0x9A2)
  lbpx  mx,  0xA2                                                                  // 0x13B7 (0x9A2)
  lbpx  mx,  0xA2                                                                  // 0x13B8 (0x9A2)
  lbpx  mx,  0x2                                                                   // 0x13B9 (0x902)
  lbpx  mx,  0xA                                                                   // 0x13BA (0x90A)
  lbpx  mx,  0x4                                                                   // 0x13BB (0x904)
  lbpx  mx,  0xF8                                                                  // 0x13BC (0x9F8)
  lbpx  mx,  0x0                                                                   // 0x13BD (0x900)
  lbpx  mx,  0x0                                                                   // 0x13BE (0x900)
  retd  0x0                                                                        // 0x13BF (0x100)
  
  // Stage 3e, Nyorotchi lower half, leaning left
  lbpx  mx,  0x0                                                                   // 0x13C0 (0x900)
  lbpx  mx,  0x0                                                                   // 0x13C1 (0x900)
  lbpx  mx,  0x0                                                                   // 0x13C2 (0x900)
  lbpx  mx,  0x1                                                                   // 0x13C3 (0x901)
  lbpx  mx,  0x2                                                                   // 0x13C4 (0x902)
  lbpx  mx,  0x4                                                                   // 0x13C5 (0x904)
  lbpx  mx,  0x4                                                                   // 0x13C6 (0x904)
  lbpx  mx,  0x1C                                                                  // 0x13C7 (0x91C)
  lbpx  mx,  0x3C                                                                  // 0x13C8 (0x93C)
  lbpx  mx,  0x64                                                                  // 0x13C9 (0x964)
  lbpx  mx,  0x44                                                                  // 0x13CA (0x944)
  lbpx  mx,  0x62                                                                  // 0x13CB (0x962)
  lbpx  mx,  0x11                                                                  // 0x13CC (0x911)
  lbpx  mx,  0x20                                                                  // 0x13CD (0x920)
  lbpx  mx,  0x40                                                                  // 0x13CE (0x940)
  retd  0x20                                                                       // 0x13CF (0x120)
  
  // Stage 3e, Nyorotchi lower half, leaning right
  lbpx  mx,  0x0                                                                   // 0x13D0 (0x900)
  lbpx  mx,  0x0                                                                   // 0x13D1 (0x900)
  lbpx  mx,  0x0                                                                   // 0x13D2 (0x900)
  lbpx  mx,  0x1                                                                   // 0x13D3 (0x901)
  lbpx  mx,  0x2                                                                   // 0x13D4 (0x902)
  lbpx  mx,  0x24                                                                  // 0x13D5 (0x924)
  lbpx  mx,  0x74                                                                  // 0x13D6 (0x974)
  lbpx  mx,  0x5C                                                                  // 0x13D7 (0x95C)
  lbpx  mx,  0x4C                                                                  // 0x13D8 (0x94C)
  lbpx  mx,  0x24                                                                  // 0x13D9 (0x924)
  lbpx  mx,  0x24                                                                  // 0x13DA (0x924)
  lbpx  mx,  0x42                                                                  // 0x13DB (0x942)
  lbpx  mx,  0x41                                                                  // 0x13DC (0x941)
  lbpx  mx,  0x30                                                                  // 0x13DD (0x930)
  lbpx  mx,  0x0                                                                   // 0x13DE (0x900)
  retd  0x0                                                                        // 0x13DF (0x100)
  
  // Stage 3e, Nyorotchi lower half, filled in
  lbpx  mx,  0x0                                                                   // 0x13E0 (0x900)
  lbpx  mx,  0x0                                                                   // 0x13E1 (0x900)
  lbpx  mx,  0x0                                                                   // 0x13E2 (0x900)
  lbpx  mx,  0x1                                                                   // 0x13E3 (0x901)
  lbpx  mx,  0x42                                                                  // 0x13E4 (0x942)
  lbpx  mx,  0x64                                                                  // 0x13E5 (0x964)
  lbpx  mx,  0x54                                                                  // 0x13E6 (0x954)
  lbpx  mx,  0x6C                                                                  // 0x13E7 (0x96C)
  lbpx  mx,  0x7C                                                                  // 0x13E8 (0x97C)
  lbpx  mx,  0x74                                                                  // 0x13E9 (0x974)
  lbpx  mx,  0x64                                                                  // 0x13EA (0x964)
  lbpx  mx,  0x42                                                                  // 0x13EB (0x942)
  lbpx  mx,  0x49                                                                  // 0x13EC (0x949)
  lbpx  mx,  0x30                                                                  // 0x13ED (0x930)
  lbpx  mx,  0x0                                                                   // 0x13EE (0x900)
  retd  0x0                                                                        // 0x13EF (0x100)
  
  // Stage 4, Bill upper half
  lbpx  mx,  0x0                                                                   // 0x13F0 (0x900)
  lbpx  mx,  0xC0                                                                  // 0x13F1 (0x9C0)
  lbpx  mx,  0xA6                                                                  // 0x13F2 (0x9A6)
  lbpx  mx,  0xB9                                                                  // 0x13F3 (0x9B9)
  lbpx  mx,  0xA5                                                                  // 0x13F4 (0x9A5)
  lbpx  mx,  0x35                                                                  // 0x13F5 (0x935)
  lbpx  mx,  0x25                                                                  // 0x13F6 (0x925)
  lbpx  mx,  0x5                                                                   // 0x13F7 (0x905)
  lbpx  mx,  0x5                                                                   // 0x13F8 (0x905)
  lbpx  mx,  0x25                                                                  // 0x13F9 (0x925)
  lbpx  mx,  0x5                                                                   // 0x13FA (0x905)
  lbpx  mx,  0x19                                                                  // 0x13FB (0x919)
  lbpx  mx,  0x12                                                                  // 0x13FC (0x912)
  lbpx  mx,  0x92                                                                  // 0x13FD (0x992)
  lbpx  mx,  0x6C                                                                  // 0x13FE (0x96C)
  retd  0x0                                                                        // 0x13FF (0x100)
  
  // Stage 4, Bill lower half
  lbpx  mx,  0x0                                                                   // 0x1400 (0x900)
  lbpx  mx,  0x50                                                                  // 0x1401 (0x950)
  lbpx  mx,  0x6B                                                                  // 0x1402 (0x96B)
  lbpx  mx,  0x44                                                                  // 0x1403 (0x944)
  lbpx  mx,  0xE                                                                   // 0x1404 (0x90E)
  lbpx  mx,  0x12                                                                  // 0x1405 (0x912)
  lbpx  mx,  0x1A                                                                  // 0x1406 (0x91A)
  lbpx  mx,  0x12                                                                  // 0x1407 (0x912)
  lbpx  mx,  0x12                                                                  // 0x1408 (0x912)
  lbpx  mx,  0x12                                                                  // 0x1409 (0x912)
  lbpx  mx,  0x18                                                                  // 0x140A (0x918)
  lbpx  mx,  0x8                                                                   // 0x140B (0x908)
  lbpx  mx,  0x44                                                                  // 0x140C (0x944)
  lbpx  mx,  0x6B                                                                  // 0x140D (0x96B)
  lbpx  mx,  0x50                                                                  // 0x140E (0x950)
  retd  0x0                                                                        // 0x140F (0x100)
  
  // Stage 4, Bill upper half, sad
  lbpx  mx,  0x0                                                                   // 0x1410 (0x900)
  lbpx  mx,  0x0                                                                   // 0x1411 (0x900)
  lbpx  mx,  0x9C                                                                  // 0x1412 (0x99C)
  lbpx  mx,  0xE2                                                                  // 0x1413 (0x9E2)
  lbpx  mx,  0x92                                                                  // 0x1414 (0x992)
  lbpx  mx,  0x8A                                                                  // 0x1415 (0x98A)
  lbpx  mx,  0x8A                                                                  // 0x1416 (0x98A)
  lbpx  mx,  0x1A                                                                  // 0x1417 (0x91A)
  lbpx  mx,  0x2A                                                                  // 0x1418 (0x92A)
  lbpx  mx,  0xAA                                                                  // 0x1419 (0x9AA)
  lbpx  mx,  0xAA                                                                  // 0x141A (0x9AA)
  lbpx  mx,  0x12                                                                  // 0x141B (0x912)
  lbpx  mx,  0x24                                                                  // 0x141C (0x924)
  lbpx  mx,  0x24                                                                  // 0x141D (0x924)
  lbpx  mx,  0xD8                                                                  // 0x141E (0x9D8)
  retd  0x0                                                                        // 0x141F (0x100)
  
  // Stage 4, Bill lower half, sad
  lbpx  mx,  0x0                                                                   // 0x1420 (0x900)
  lbpx  mx,  0x53                                                                  // 0x1421 (0x953)
  lbpx  mx,  0x6E                                                                  // 0x1422 (0x96E)
  lbpx  mx,  0x52                                                                  // 0x1423 (0x952)
  lbpx  mx,  0x7A                                                                  // 0x1424 (0x97A)
  lbpx  mx,  0x48                                                                  // 0x1425 (0x948)
  lbpx  mx,  0x68                                                                  // 0x1426 (0x968)
  lbpx  mx,  0x48                                                                  // 0x1427 (0x948)
  lbpx  mx,  0x48                                                                  // 0x1428 (0x948)
  lbpx  mx,  0x50                                                                  // 0x1429 (0x950)
  lbpx  mx,  0x60                                                                  // 0x142A (0x960)
  lbpx  mx,  0x60                                                                  // 0x142B (0x960)
  lbpx  mx,  0x50                                                                  // 0x142C (0x950)
  lbpx  mx,  0x6F                                                                  // 0x142D (0x96F)
  lbpx  mx,  0x50                                                                  // 0x142E (0x950)
  retd  0x0                                                                        // 0x142F (0x100)
  
  // Stage 4, Bill upper half, Laughing
  lbpx  mx,  0x40                                                                  // 0x1430 (0x940)
  lbpx  mx,  0xA0                                                                  // 0x1431 (0x9A0)
  lbpx  mx,  0xF8                                                                  // 0x1432 (0x9F8)
  lbpx  mx,  0x4                                                                   // 0x1433 (0x904)
  lbpx  mx,  0x7A                                                                  // 0x1434 (0x97A)
  lbpx  mx,  0xEA                                                                  // 0x1435 (0x9EA)
  lbpx  mx,  0xBF                                                                  // 0x1436 (0x9BF)
  lbpx  mx,  0xE9                                                                  // 0x1437 (0x9E9)
  lbpx  mx,  0xBD                                                                  // 0x1438 (0x9BD)
  lbpx  mx,  0xEA                                                                  // 0x1439 (0x9EA)
  lbpx  mx,  0x7A                                                                  // 0x143A (0x97A)
  lbpx  mx,  0x2                                                                   // 0x143B (0x902)
  lbpx  mx,  0x4                                                                   // 0x143C (0x904)
  lbpx  mx,  0xF8                                                                  // 0x143D (0x9F8)
  lbpx  mx,  0xA0                                                                  // 0x143E (0x9A0)
  retd  0x40                                                                       // 0x143F (0x140)
  
  // Stage 4, Bill upper half, sleeping
  lbpx  mx,  0x0                                                                   // 0x1440 (0x900)
  lbpx  mx,  0xC0                                                                  // 0x1441 (0x9C0)
  lbpx  mx,  0xA6                                                                  // 0x1442 (0x9A6)
  lbpx  mx,  0xB9                                                                  // 0x1443 (0x9B9)
  lbpx  mx,  0xA5                                                                  // 0x1444 (0x9A5)
  lbpx  mx,  0x25                                                                  // 0x1445 (0x925)
  lbpx  mx,  0x25                                                                  // 0x1446 (0x925)
  lbpx  mx,  0x5                                                                   // 0x1447 (0x905)
  lbpx  mx,  0x15                                                                  // 0x1448 (0x915)
  lbpx  mx,  0x25                                                                  // 0x1449 (0x925)
  lbpx  mx,  0x25                                                                  // 0x144A (0x925)
  lbpx  mx,  0x9                                                                   // 0x144B (0x909)
  lbpx  mx,  0x12                                                                  // 0x144C (0x912)
  lbpx  mx,  0x92                                                                  // 0x144D (0x992)
  lbpx  mx,  0x6C                                                                  // 0x144E (0x96C)
  retd  0x0                                                                        // 0x144F (0x100)
  
  // Cloud?
  // TODO: What is this?
  lbpx  mx,  0x0                                                                   // 0x1450 (0x900)
  lbpx  mx,  0x0                                                                   // 0x1451 (0x900)
  lbpx  mx,  0x0                                                                   // 0x1452 (0x900)
  lbpx  mx,  0xFC                                                                  // 0x1453 (0x9FC)
  lbpx  mx,  0x42                                                                  // 0x1454 (0x942)
  lbpx  mx,  0x81                                                                  // 0x1455 (0x981)
  lbpx  mx,  0x81                                                                  // 0x1456 (0x981)
  lbpx  mx,  0x81                                                                  // 0x1457 (0x981)
  lbpx  mx,  0x82                                                                  // 0x1458 (0x982)
  lbpx  mx,  0x81                                                                  // 0x1459 (0x981)
  lbpx  mx,  0x81                                                                  // 0x145A (0x981)
  lbpx  mx,  0x81                                                                  // 0x145B (0x981)
  lbpx  mx,  0x81                                                                  // 0x145C (0x981)
  lbpx  mx,  0x42                                                                  // 0x145D (0x942)
  lbpx  mx,  0xFC                                                                  // 0x145E (0x9FC)
  retd  0x0                                                                        // 0x145F (0x100)
  
  // Egg, upper half, position 1
  lbpx  mx,  0x0                                                                   // 0x1460 (0x900)
  lbpx  mx,  0x0                                                                   // 0x1461 (0x900)
  lbpx  mx,  0x0                                                                   // 0x1462 (0x900)
  lbpx  mx,  0xC0                                                                  // 0x1463 (0x9C0)
  lbpx  mx,  0xF0                                                                  // 0x1464 (0x9F0)
  lbpx  mx,  0xC8                                                                  // 0x1465 (0x9C8)
  lbpx  mx,  0xE4                                                                  // 0x1466 (0x9E4)
  lbpx  mx,  0x7C                                                                  // 0x1467 (0x97C)
  lbpx  mx,  0x7C                                                                  // 0x1468 (0x97C)
  lbpx  mx,  0xCC                                                                  // 0x1469 (0x9CC)
  lbpx  mx,  0xD8                                                                  // 0x146A (0x9D8)
  lbpx  mx,  0xF0                                                                  // 0x146B (0x9F0)
  lbpx  mx,  0xC0                                                                  // 0x146C (0x9C0)
  lbpx  mx,  0x0                                                                   // 0x146D (0x900)
  lbpx  mx,  0x0                                                                   // 0x146E (0x900)
  retd  0x0                                                                        // 0x146F (0x100)
  
  // Egg, lower half, position 1
  lbpx  mx,  0x0                                                                   // 0x1470 (0x900)
  lbpx  mx,  0x0                                                                   // 0x1471 (0x900)
  lbpx  mx,  0x0                                                                   // 0x1472 (0x900)
  lbpx  mx,  0x3                                                                   // 0x1473 (0x903)
  lbpx  mx,  0x15                                                                  // 0x1474 (0x915)
  lbpx  mx,  0x19                                                                  // 0x1475 (0x919)
  lbpx  mx,  0x1B                                                                  // 0x1476 (0x91B)
  lbpx  mx,  0x1E                                                                  // 0x1477 (0x91E)
  lbpx  mx,  0x16                                                                  // 0x1478 (0x916)
  lbpx  mx,  0x17                                                                  // 0x1479 (0x917)
  lbpx  mx,  0x1C                                                                  // 0x147A (0x91C)
  lbpx  mx,  0x16                                                                  // 0x147B (0x916)
  lbpx  mx,  0x3                                                                   // 0x147C (0x903)
  lbpx  mx,  0x0                                                                   // 0x147D (0x900)
  lbpx  mx,  0x0                                                                   // 0x147E (0x900)
  retd  0x0                                                                        // 0x147F (0x100)
  
  // Egg, upper half, position 2
  lbpx  mx,  0x0                                                                   // 0x1480 (0x900)
  lbpx  mx,  0x0                                                                   // 0x1481 (0x900)
  lbpx  mx,  0x80                                                                  // 0x1482 (0x980)
  lbpx  mx,  0xC0                                                                  // 0x1483 (0x9C0)
  lbpx  mx,  0x20                                                                  // 0x1484 (0x920)
  lbpx  mx,  0x90                                                                  // 0x1485 (0x990)
  lbpx  mx,  0xF0                                                                  // 0x1486 (0x9F0)
  lbpx  mx,  0xF8                                                                  // 0x1487 (0x9F8)
  lbpx  mx,  0xF8                                                                  // 0x1488 (0x9F8)
  lbpx  mx,  0xF0                                                                  // 0x1489 (0x9F0)
  lbpx  mx,  0x90                                                                  // 0x148A (0x990)
  lbpx  mx,  0xA0                                                                  // 0x148B (0x9A0)
  lbpx  mx,  0xC0                                                                  // 0x148C (0x9C0)
  lbpx  mx,  0x80                                                                  // 0x148D (0x980)
  lbpx  mx,  0x0                                                                   // 0x148E (0x900)
  retd  0x0                                                                        // 0x148F (0x100)
  
  // Egg, lower half, position 2
  lbpx  mx,  0x0                                                                   // 0x1490 (0x900)
  lbpx  mx,  0x0                                                                   // 0x1491 (0x900)
  lbpx  mx,  0x3                                                                   // 0x1492 (0x903)
  lbpx  mx,  0x15                                                                  // 0x1493 (0x915)
  lbpx  mx,  0x19                                                                  // 0x1494 (0x919)
  lbpx  mx,  0x1B                                                                  // 0x1495 (0x91B)
  lbpx  mx,  0x1F                                                                  // 0x1496 (0x91F)
  lbpx  mx,  0x1C                                                                  // 0x1497 (0x91C)
  lbpx  mx,  0x1C                                                                  // 0x1498 (0x91C)
  lbpx  mx,  0x1F                                                                  // 0x1499 (0x91F)
  lbpx  mx,  0x13                                                                  // 0x149A (0x913)
  lbpx  mx,  0x1B                                                                  // 0x149B (0x91B)
  lbpx  mx,  0x17                                                                  // 0x149C (0x917)
  lbpx  mx,  0x3                                                                   // 0x149D (0x903)
  lbpx  mx,  0x0                                                                   // 0x149E (0x900)
  retd  0x0                                                                        // 0x149F (0x100)
  
  // Egg hatching, upper half
  lbpx  mx,  0x38                                                                  // 0x14A0 (0x938)
  lbpx  mx,  0xA6                                                                  // 0x14A1 (0x9A6)
  lbpx  mx,  0x13                                                                  // 0x14A2 (0x913)
  lbpx  mx,  0xF                                                                   // 0x14A3 (0x90F)
  lbpx  mx,  0x3                                                                   // 0x14A4 (0x903)
  lbpx  mx,  0xE0                                                                  // 0x14A5 (0x9E0)
  lbpx  mx,  0xD0                                                                  // 0x14A6 (0x9D0)
  lbpx  mx,  0x31                                                                  // 0x14A7 (0x931)
  lbpx  mx,  0x30                                                                  // 0x14A8 (0x930)
  lbpx  mx,  0xD0                                                                  // 0x14A9 (0x9D0)
  lbpx  mx,  0xE2                                                                  // 0x14AA (0x9E2)
  lbpx  mx,  0xF                                                                   // 0x14AB (0x90F)
  lbpx  mx,  0x13                                                                  // 0x14AC (0x913)
  lbpx  mx,  0x16                                                                  // 0x14AD (0x916)
  lbpx  mx,  0x48                                                                  // 0x14AE (0x948)
  retd  0x1                                                                        // 0x14AF (0x101)
  
  // Egg hatching, lower half
  lbpx  mx,  0x0                                                                   // 0x14B0 (0x900)
  lbpx  mx,  0x10                                                                  // 0x14B1 (0x910)
  lbpx  mx,  0x0                                                                   // 0x14B2 (0x900)
  lbpx  mx,  0x3                                                                   // 0x14B3 (0x903)
  lbpx  mx,  0x15                                                                  // 0x14B4 (0x915)
  lbpx  mx,  0x19                                                                  // 0x14B5 (0x919)
  lbpx  mx,  0x1B                                                                  // 0x14B6 (0x91B)
  lbpx  mx,  0x1F                                                                  // 0x14B7 (0x91F)
  lbpx  mx,  0x17                                                                  // 0x14B8 (0x917)
  lbpx  mx,  0x17                                                                  // 0x14B9 (0x917)
  lbpx  mx,  0x1D                                                                  // 0x14BA (0x91D)
  lbpx  mx,  0x16                                                                  // 0x14BB (0x916)
  lbpx  mx,  0x3                                                                   // 0x14BC (0x903)
  lbpx  mx,  0x0                                                                   // 0x14BD (0x900)
  lbpx  mx,  0x8                                                                   // 0x14BE (0x908)
  retd  0x0                                                                        // 0x14BF (0x100)
  
  // Sparkles, large one on the left
  lbpx  mx,  0x41                                                                  // 0x14C0 (0x941)
  lbpx  mx,  0x2A                                                                  // 0x14C1 (0x92A)
  lbpx  mx,  0x8                                                                   // 0x14C2 (0x908)
  lbpx  mx,  0x36                                                                  // 0x14C3 (0x936)
  lbpx  mx,  0x8                                                                   // 0x14C4 (0x908)
  lbpx  mx,  0x2A                                                                  // 0x14C5 (0x92A)
  lbpx  mx,  0x41                                                                  // 0x14C6 (0x941)
  lbpx  mx,  0x0                                                                   // 0x14C7 (0x900)
  lbpx  mx,  0x0                                                                   // 0x14C8 (0x900)
  lbpx  mx,  0x0                                                                   // 0x14C9 (0x900)
  lbpx  mx,  0x8                                                                   // 0x14CA (0x908)
  lbpx  mx,  0x14                                                                  // 0x14CB (0x914)
  lbpx  mx,  0x8                                                                   // 0x14CC (0x908)
  lbpx  mx,  0x0                                                                   // 0x14CD (0x900)
  lbpx  mx,  0x0                                                                   // 0x14CE (0x900)
  retd  0x0                                                                        // 0x14CF (0x100)
  
  // Sparkles, large one on the right
  lbpx  mx,  0x0                                                                   // 0x14D0 (0x900)
  lbpx  mx,  0x0                                                                   // 0x14D1 (0x900)
  lbpx  mx,  0x20                                                                  // 0x14D2 (0x920)
  lbpx  mx,  0x50                                                                  // 0x14D3 (0x950)
  lbpx  mx,  0x20                                                                  // 0x14D4 (0x920)
  lbpx  mx,  0x0                                                                   // 0x14D5 (0x900)
  lbpx  mx,  0x0                                                                   // 0x14D6 (0x900)
  lbpx  mx,  0x0                                                                   // 0x14D7 (0x900)
  lbpx  mx,  0x0                                                                   // 0x14D8 (0x900)
  lbpx  mx,  0x22                                                                  // 0x14D9 (0x922)
  lbpx  mx,  0x8                                                                   // 0x14DA (0x908)
  lbpx  mx,  0x14                                                                  // 0x14DB (0x914)
  lbpx  mx,  0x8                                                                   // 0x14DC (0x908)
  lbpx  mx,  0x22                                                                  // 0x14DD (0x922)
  lbpx  mx,  0x0                                                                   // 0x14DE (0x900)
  retd  0x0                                                                        // 0x14DF (0x100)
  
  // Angel, upper half
  lbpx  mx,  0x80                                                                  // 0x14E0 (0x980)
  lbpx  mx,  0x40                                                                  // 0x14E1 (0x940)
  lbpx  mx,  0xF0                                                                  // 0x14E2 (0x9F0)
  lbpx  mx,  0x8                                                                   // 0x14E3 (0x908)
  lbpx  mx,  0x24                                                                  // 0x14E4 (0x924)
  lbpx  mx,  0x8E                                                                  // 0x14E5 (0x98E)
  lbpx  mx,  0x96                                                                  // 0x14E6 (0x996)
  lbpx  mx,  0x6                                                                   // 0x14E7 (0x906)
  lbpx  mx,  0x24                                                                  // 0x14E8 (0x924)
  lbpx  mx,  0x8                                                                   // 0x14E9 (0x908)
  lbpx  mx,  0xF0                                                                  // 0x14EA (0x9F0)
  lbpx  mx,  0x40                                                                  // 0x14EB (0x940)
  lbpx  mx,  0x40                                                                  // 0x14EC (0x940)
  lbpx  mx,  0x80                                                                  // 0x14ED (0x980)
  lbpx  mx,  0x0                                                                   // 0x14EE (0x900)
  retd  0x0                                                                        // 0x14EF (0x100)
  
  // Angel, lower half
  lbpx  mx,  0x7                                                                   // 0x14F0 (0x907)
  lbpx  mx,  0x8                                                                   // 0x14F1 (0x908)
  lbpx  mx,  0x4                                                                   // 0x14F2 (0x904)
  lbpx  mx,  0x5                                                                   // 0x14F3 (0x905)
  lbpx  mx,  0xE                                                                   // 0x14F4 (0x90E)
  lbpx  mx,  0x12                                                                  // 0x14F5 (0x912)
  lbpx  mx,  0x22                                                                  // 0x14F6 (0x922)
  lbpx  mx,  0x22                                                                  // 0x14F7 (0x922)
  lbpx  mx,  0x62                                                                  // 0x14F8 (0x962)
  lbpx  mx,  0x15                                                                  // 0x14F9 (0x915)
  lbpx  mx,  0x3C                                                                  // 0x14FA (0x93C)
  lbpx  mx,  0x4                                                                   // 0x14FB (0x904)
  lbpx  mx,  0x8                                                                   // 0x14FC (0x908)
  lbpx  mx,  0x7                                                                   // 0x14FD (0x907)
  lbpx  mx,  0x0                                                                   // 0x14FE (0x900)
  retd  0x0                                                                        // 0x14FF (0x100)
  
  // Large 0 text
  lbpx  mx,  0x3E                                                                  // 0x1500 (0x93E)
  lbpx  mx,  0x41                                                                  // 0x1501 (0x941)
  lbpx  mx,  0x41                                                                  // 0x1502 (0x941)
  retd  0x3E                                                                       // 0x1503 (0x13E)
  
  // Large 1 text
  lbpx  mx,  0x0                                                                   // 0x1504 (0x900)
  lbpx  mx,  0x0                                                                   // 0x1505 (0x900)
  lbpx  mx,  0x2                                                                   // 0x1506 (0x902)
  retd  0x7F                                                                       // 0x1507 (0x17F)
  
  // Large 2 text
  lbpx  mx,  0x62                                                                  // 0x1508 (0x962)
  lbpx  mx,  0x51                                                                  // 0x1509 (0x951)
  lbpx  mx,  0x49                                                                  // 0x150A (0x949)
  retd  0x46                                                                       // 0x150B (0x146)
  
  // Large 3 text
  lbpx  mx,  0x41                                                                  // 0x150C (0x941)
  lbpx  mx,  0x49                                                                  // 0x150D (0x949)
  lbpx  mx,  0x49                                                                  // 0x150E (0x949)
  retd  0x36                                                                       // 0x150F (0x136)
  
  // Large 4 text
  lbpx  mx,  0x3C                                                                  // 0x1510 (0x93C)
  lbpx  mx,  0x22                                                                  // 0x1511 (0x922)
  lbpx  mx,  0x7F                                                                  // 0x1512 (0x97F)
  retd  0x20                                                                       // 0x1513 (0x120)
  
  // Large 5 text
  lbpx  mx,  0x4F                                                                  // 0x1514 (0x94F)
  lbpx  mx,  0x49                                                                  // 0x1515 (0x949)
  lbpx  mx,  0x49                                                                  // 0x1516 (0x949)
  retd  0x31                                                                       // 0x1517 (0x131)
  
  // Large 6 text
  lbpx  mx,  0x3E                                                                  // 0x1518 (0x93E)
  lbpx  mx,  0x49                                                                  // 0x1519 (0x949)
  lbpx  mx,  0x49                                                                  // 0x151A (0x949)
  retd  0x32                                                                       // 0x151B (0x132)
  
  // Large 7 text
  lbpx  mx,  0x7                                                                   // 0x151C (0x907)
  lbpx  mx,  0x1                                                                   // 0x151D (0x901)
  lbpx  mx,  0x71                                                                  // 0x151E (0x971)
  retd  0xF                                                                        // 0x151F (0x10F)
  
  // Large 8 text
  lbpx  mx,  0x36                                                                  // 0x1520 (0x936)
  lbpx  mx,  0x49                                                                  // 0x1521 (0x949)
  lbpx  mx,  0x49                                                                  // 0x1522 (0x949)
  retd  0x36                                                                       // 0x1523 (0x136)
  
  // Large 9 text
  lbpx  mx,  0x6                                                                   // 0x1524 (0x906)
  lbpx  mx,  0x49                                                                  // 0x1525 (0x949)
  lbpx  mx,  0x49                                                                  // 0x1526 (0x949)
  retd  0x3E                                                                       // 0x1527 (0x13E)
  
  // Small 0 text
  lbpx  mx,  0x7C                                                                  // 0x1528 (0x97C)
  lbpx  mx,  0x44                                                                  // 0x1529 (0x944)
  retd  0x7C                                                                       // 0x152A (0x17C)
  retd  0x0                                                                        // 0x152B (0x100)
  
  // Small 1 text
  lbpx  mx,  0x0                                                                   // 0x152C (0x900)
  lbpx  mx,  0x0                                                                   // 0x152D (0x900)
  retd  0x7C                                                                       // 0x152E (0x17C)
  retd  0x0                                                                        // 0x152F (0x100)
  
  // Small 2 text
  lbpx  mx,  0x74                                                                  // 0x1530 (0x974)
  lbpx  mx,  0x54                                                                  // 0x1531 (0x954)
  retd  0x5C                                                                       // 0x1532 (0x15C)
  retd  0x0                                                                        // 0x1533 (0x100)
  
  // Small 3 text
  lbpx  mx,  0x54                                                                  // 0x1534 (0x954)
  lbpx  mx,  0x54                                                                  // 0x1535 (0x954)
  retd  0x7C                                                                       // 0x1536 (0x17C)
  retd  0x0                                                                        // 0x1537 (0x100)
  
  // Small 4 text
  lbpx  mx,  0x1C                                                                  // 0x1538 (0x91C)
  lbpx  mx,  0x10                                                                  // 0x1539 (0x910)
  retd  0x7C                                                                       // 0x153A (0x17C)
  retd  0x0                                                                        // 0x153B (0x100)
  
  // Small 5 text  
  lbpx  mx,  0x5C                                                                  // 0x153C (0x95C)
  lbpx  mx,  0x54                                                                  // 0x153D (0x954)
  retd  0x74                                                                       // 0x153E (0x174)
  retd  0x0                                                                        // 0x153F (0x100)
  
  // Small 6 text
  lbpx  mx,  0x7C                                                                  // 0x1540 (0x97C)
  lbpx  mx,  0x54                                                                  // 0x1541 (0x954)
  retd  0x74                                                                       // 0x1542 (0x174)
  retd  0x0                                                                        // 0x1543 (0x100)
  
  // Small 7 text
  lbpx  mx,  0xC                                                                   // 0x1544 (0x90C)
  lbpx  mx,  0x4                                                                   // 0x1545 (0x904)
  retd  0x7C                                                                       // 0x1546 (0x17C)
  retd  0x0                                                                        // 0x1547 (0x100)
  
  // Small 8 text
  lbpx  mx,  0x7C                                                                  // 0x1548 (0x97C)
  lbpx  mx,  0x54                                                                  // 0x1549 (0x954)
  retd  0x7C                                                                       // 0x154A (0x17C)
  retd  0x0                                                                        // 0x154B (0x100)
  
  // Small 9 text
  lbpx  mx,  0x5C                                                                  // 0x154C (0x95C)
  lbpx  mx,  0x54                                                                  // 0x154D (0x954)
  retd  0x7C                                                                       // 0x154E (0x17C)
  retd  0x0                                                                        // 0x154F (0x100)
  
  // Filled in right pointing arrow
  lbpx  mx,  0x7C                                                                  // 0x1550 (0x97C)
  lbpx  mx,  0x38                                                                  // 0x1551 (0x938)
  retd  0x10                                                                       // 0x1552 (0x110)
  retd  0x0                                                                        // 0x1553 (0x100)
  
  // Unfilled right pointing arrow
  lbpx  mx,  0x44                                                                  // 0x1554 (0x944)
  lbpx  mx,  0x28                                                                  // 0x1555 (0x928)
  retd  0x10                                                                       // 0x1556 (0x110)
  retd  0x0                                                                        // 0x1557 (0x100)
  jp    label_397                                                                  // 0x1558 (0x64)
  jp    label_397                                                                  // 0x1559 (0x64)
  jp    label_398                                                                  // 0x155A (0x71)
  jp    label_399                                                                  // 0x155B (0x7E)
  jp    label_400                                                                  // 0x155C (0x8B)
  jp    label_401                                                                  // 0x155D (0x98)
  jp    label_402                                                                  // 0x155E (0xA5)
  jp    label_403                                                                  // 0x155F (0xB2)
  jp    label_404                                                                  // 0x1560 (0xBF)
  jp    label_405                                                                  // 0x1561 (0xCC)
  jp    label_406                                                                  // 0x1562 (0xD9)
  jp    label_401                                                                  // 0x1563 (0x98)

// TODO: Unclear what any of these are. Are these not for video RAM?

label_397:
  lbpx  mx,  0xFF                                                                  // 0x1564 (0x9FF)
  lbpx  mx,  0xFF                                                                  // 0x1565 (0x9FF)
  lbpx  mx,  0x3                                                                   // 0x1566 (0x903)
  lbpx  mx,  0x4                                                                   // 0x1567 (0x904)
  lbpx  mx,  0x2D                                                                  // 0x1568 (0x92D)
  lbpx  mx,  0xC0                                                                  // 0x1569 (0x9C0)
  lbpx  mx,  0x5                                                                   // 0x156A (0x905)
  lbpx  mx,  0x5                                                                   // 0x156B (0x905)
  lbpx  mx,  0x3C                                                                  // 0x156C (0x93C)
  lbpx  mx,  0xF0                                                                  // 0x156D (0x9F0)
  lbpx  mx,  0x80                                                                  // 0x156E (0x980)
  lbpx  mx,  0x11                                                                  // 0x156F (0x911)
  retd  0x0                                                                        // 0x1570 (0x100)

label_398:
  lbpx  mx,  0x9                                                                   // 0x1571 (0x909)
  lbpx  mx,  0x14                                                                  // 0x1572 (0x914)
  lbpx  mx,  0x32                                                                  // 0x1573 (0x932)
  lbpx  mx,  0x3C                                                                  // 0x1574 (0x93C)
  lbpx  mx,  0xDE                                                                  // 0x1575 (0x9DE)
  lbpx  mx,  0xC3                                                                  // 0x1576 (0x9C3)
  lbpx  mx,  0x10                                                                  // 0x1577 (0x910)
  lbpx  mx,  0x99                                                                  // 0x1578 (0x999)
  lbpx  mx,  0x64                                                                  // 0x1579 (0x964)
  lbpx  mx,  0x65                                                                  // 0x157A (0x965)
  lbpx  mx,  0x80                                                                  // 0x157B (0x980)
  lbpx  mx,  0x11                                                                  // 0x157C (0x911)
  retd  0x0                                                                        // 0x157D (0x100)

label_399:
  lbpx  mx,  0x9                                                                   // 0x157E (0x909)
  lbpx  mx,  0x15                                                                  // 0x157F (0x915)
  lbpx  mx,  0x4B                                                                  // 0x1580 (0x94B)
  lbpx  mx,  0x55                                                                  // 0x1581 (0x955)
  lbpx  mx,  0x78                                                                  // 0x1582 (0x978)
  lbpx  mx,  0xC6                                                                  // 0x1583 (0x9C6)
  lbpx  mx,  0x20                                                                  // 0x1584 (0x920)
  lbpx  mx,  0x99                                                                  // 0x1585 (0x999)
  lbpx  mx,  0xAC                                                                  // 0x1586 (0x9AC)
  lbpx  mx,  0x68                                                                  // 0x1587 (0x968)
  lbpx  mx,  0x80                                                                  // 0x1588 (0x980)
  lbpx  mx,  0x11                                                                  // 0x1589 (0x911)
  retd  0x1                                                                        // 0x158A (0x101)

label_400:
  lbpx  mx,  0x9                                                                   // 0x158B (0x909)
  lbpx  mx,  0x15                                                                  // 0x158C (0x915)
  lbpx  mx,  0x4B                                                                  // 0x158D (0x94B)
  lbpx  mx,  0x55                                                                  // 0x158E (0x955)
  lbpx  mx,  0x94                                                                  // 0x158F (0x994)
  lbpx  mx,  0xC2                                                                  // 0x1590 (0x9C2)
  lbpx  mx,  0x20                                                                  // 0x1591 (0x920)
  lbpx  mx,  0x99                                                                  // 0x1592 (0x999)
  lbpx  mx,  0x64                                                                  // 0x1593 (0x964)
  lbpx  mx,  0x65                                                                  // 0x1594 (0x965)
  lbpx  mx,  0x80                                                                  // 0x1595 (0x980)
  lbpx  mx,  0x11                                                                  // 0x1596 (0x911)
  retd  0x0                                                                        // 0x1597 (0x100)

label_401:
  lbpx  mx,  0x9                                                                   // 0x1598 (0x909)
  lbpx  mx,  0x16                                                                  // 0x1599 (0x916)
  lbpx  mx,  0x51                                                                  // 0x159A (0x951)
  lbpx  mx,  0x5B                                                                  // 0x159B (0x95B)
  lbpx  mx,  0x3C                                                                  // 0x159C (0x93C)
  lbpx  mx,  0x8F                                                                  // 0x159D (0x98F)
  lbpx  mx,  0x30                                                                  // 0x159E (0x930)
  lbpx  mx,  0x99                                                                  // 0x159F (0x999)
  lbpx  mx,  0xFF                                                                  // 0x15A0 (0x9FF)
  lbpx  mx,  0xFF                                                                  // 0x15A1 (0x9FF)
  lbpx  mx,  0x8F                                                                  // 0x15A2 (0x98F)
  lbpx  mx,  0x11                                                                  // 0x15A3 (0x911)
  retd  0x1                                                                        // 0x15A4 (0x101)

label_402:
  lbpx  mx,  0x9                                                                   // 0x15A5 (0x909)
  lbpx  mx,  0x16                                                                  // 0x15A6 (0x916)
  lbpx  mx,  0x51                                                                  // 0x15A7 (0x951)
  lbpx  mx,  0x5B                                                                  // 0x15A8 (0x95B)
  lbpx  mx,  0xF8                                                                  // 0x15A9 (0x9F8)
  lbpx  mx,  0x8A                                                                  // 0x15AA (0x98A)
  lbpx  mx,  0x30                                                                  // 0x15AB (0x930)
  lbpx  mx,  0x99                                                                  // 0x15AC (0x999)
  lbpx  mx,  0x30                                                                  // 0x15AD (0x930)
  lbpx  mx,  0x7C                                                                  // 0x15AE (0x97C)
  lbpx  mx,  0x88                                                                  // 0x15AF (0x988)
  lbpx  mx,  0x11                                                                  // 0x15B0 (0x911)
  retd  0x1                                                                        // 0x15B1 (0x101)

label_403:
  lbpx  mx,  0xB                                                                   // 0x15B2 (0x90B)
  lbpx  mx,  0x17                                                                  // 0x15B3 (0x917)
  lbpx  mx,  0x37                                                                  // 0x15B4 (0x937)
  lbpx  mx,  0x41                                                                  // 0x15B5 (0x941)
  lbpx  mx,  0x20                                                                  // 0x15B6 (0x920)
  lbpx  mx,  0x8A                                                                  // 0x15B7 (0x98A)
  lbpx  mx,  0x30                                                                  // 0x15B8 (0x930)
  lbpx  mx,  0x99                                                                  // 0x15B9 (0x999)
  lbpx  mx,  0x40                                                                  // 0x15BA (0x940)
  lbpx  mx,  0x7B                                                                  // 0x15BB (0x97B)
  lbpx  mx,  0xB0                                                                  // 0x15BC (0x9B0)
  lbpx  mx,  0x23                                                                  // 0x15BD (0x923)
  retd  0x1                                                                        // 0x15BE (0x101)

label_404:
  lbpx  mx,  0x9                                                                   // 0x15BF (0x909)
  lbpx  mx,  0x16                                                                  // 0x15C0 (0x916)
  lbpx  mx,  0x3C                                                                  // 0x15C1 (0x93C)
  lbpx  mx,  0x46                                                                  // 0x15C2 (0x946)
  lbpx  mx,  0x92                                                                  // 0x15C3 (0x992)
  lbpx  mx,  0xC4                                                                  // 0x15C4 (0x9C4)
  lbpx  mx,  0x20                                                                  // 0x15C5 (0x920)
  lbpx  mx,  0x99                                                                  // 0x15C6 (0x999)
  lbpx  mx,  0x18                                                                  // 0x15C7 (0x918)
  lbpx  mx,  0xF6                                                                  // 0x15C8 (0x9F6)
  lbpx  mx,  0x5F                                                                  // 0x15C9 (0x95F)
  lbpx  mx,  0x43                                                                  // 0x15CA (0x943)
  retd  0x1                                                                        // 0x15CB (0x101)

label_405:
  lbpx  mx,  0x9                                                                   // 0x15CC (0x909)
  lbpx  mx,  0x16                                                                  // 0x15CD (0x916)
  lbpx  mx,  0x3C                                                                  // 0x15CE (0x93C)
  lbpx  mx,  0x46                                                                  // 0x15CF (0x946)
  lbpx  mx,  0x68                                                                  // 0x15D0 (0x968)
  lbpx  mx,  0xD1                                                                  // 0x15D1 (0x9D1)
  lbpx  mx,  0x10                                                                  // 0x15D2 (0x910)
  lbpx  mx,  0x99                                                                  // 0x15D3 (0x999)
  lbpx  mx,  0xC                                                                   // 0x15D4 (0x90C)
  lbpx  mx,  0x73                                                                  // 0x15D5 (0x973)
  lbpx  mx,  0x88                                                                  // 0x15D6 (0x988)
  lbpx  mx,  0x11                                                                  // 0x15D7 (0x911)
  retd  0x0                                                                        // 0x15D8 (0x100)

label_406:
  lbpx  mx,  0xA                                                                   // 0x15D9 (0x90A)
  lbpx  mx,  0x16                                                                  // 0x15DA (0x916)
  lbpx  mx,  0x2D                                                                  // 0x15DB (0x92D)
  lbpx  mx,  0x32                                                                  // 0x15DC (0x932)
  lbpx  mx,  0x94                                                                  // 0x15DD (0x994)
  lbpx  mx,  0xC2                                                                  // 0x15DE (0x9C2)
  lbpx  mx,  0x20                                                                  // 0x15DF (0x920)
  lbpx  mx,  0x99                                                                  // 0x15E0 (0x999)
  lbpx  mx,  0xA0                                                                  // 0x15E1 (0x9A0)
  lbpx  mx,  0x75                                                                  // 0x15E2 (0x975)
  lbpx  mx,  0x80                                                                  // 0x15E3 (0x980)
  lbpx  mx,  0x11                                                                  // 0x15E4 (0x911)
  retd  0x1                                                                        // 0x15E5 (0x101)
  retd  0x12                                                                       // 0x15E6 (0x112)
  retd  0x1                                                                        // 0x15E7 (0x101)
  retd  0x2                                                                        // 0x15E8 (0x102)
  retd  0x3                                                                        // 0x15E9 (0x103)
  retd  0x4                                                                        // 0x15EA (0x104)
  retd  0x5                                                                        // 0x15EB (0x105)
  retd  0x6                                                                        // 0x15EC (0x106)
  retd  0x7                                                                        // 0x15ED (0x107)
  retd  0x8                                                                        // 0x15EE (0x108)
  retd  0x9                                                                        // 0x15EF (0x109)
  retd  0x10                                                                       // 0x15F0 (0x110)
  retd  0x11                                                                       // 0x15F1 (0x111)
  retd  0x92                                                                       // 0x15F2 (0x192)
  retd  0x81                                                                       // 0x15F3 (0x181)
  retd  0x82                                                                       // 0x15F4 (0x182)
  retd  0x83                                                                       // 0x15F5 (0x183)
  retd  0x84                                                                       // 0x15F6 (0x184)
  retd  0x85                                                                       // 0x15F7 (0x185)
  retd  0x86                                                                       // 0x15F8 (0x186)
  retd  0x87                                                                       // 0x15F9 (0x187)
  retd  0x88                                                                       // 0x15FA (0x188)
  retd  0x89                                                                       // 0x15FB (0x189)
  retd  0x90                                                                       // 0x15FC (0x190)
  retd  0x91                                                                       // 0x15FD (0x191)
  nop7                                                                             // 0x15FE (0xFFF)
  nop7                                                                             // 0x15FF (0xFFF)
  
  // Large, centered 0 text
  // Probably used for the first digit of the hour
  lbpx  mx,  0x0                                                                   // 0x1600 (0x900)
  lbpx  mx,  0x0                                                                   // 0x1601 (0x900)
  lbpx  mx,  0x7C                                                                  // 0x1602 (0x97C)
  lbpx  mx,  0x82                                                                  // 0x1603 (0x982)
  lbpx  mx,  0x82                                                                  // 0x1604 (0x982)
  lbpx  mx,  0x7C                                                                  // 0x1605 (0x97C)
  lbpx  mx,  0x0                                                                   // 0x1606 (0x900)
  retd  0x0                                                                        // 0x1607 (0x100)
  
  // Large, centered 1 text
  lbpx  mx,  0x0                                                                   // 0x1608 (0x900)
  lbpx  mx,  0x0                                                                   // 0x1609 (0x900)
  lbpx  mx,  0x0                                                                   // 0x160A (0x900)
  lbpx  mx,  0x4                                                                   // 0x160B (0x904)
  lbpx  mx,  0xFE                                                                  // 0x160C (0x9FE)
  lbpx  mx,  0x0                                                                   // 0x160D (0x900)
  lbpx  mx,  0x0                                                                   // 0x160E (0x900)
  retd  0x0                                                                        // 0x160F (0x100)
  
  // Large, centered 2 text
  lbpx  mx,  0x0                                                                   // 0x1610 (0x900)
  lbpx  mx,  0x0                                                                   // 0x1611 (0x900)
  lbpx  mx,  0xCC                                                                  // 0x1612 (0x9CC)
  lbpx  mx,  0xA2                                                                  // 0x1613 (0x9A2)
  lbpx  mx,  0x92                                                                  // 0x1614 (0x992)
  lbpx  mx,  0x8C                                                                  // 0x1615 (0x98C)
  lbpx  mx,  0x0                                                                   // 0x1616 (0x900)
  retd  0x0                                                                        // 0x1617 (0x100)
  
  // Large, centered 3 text
  lbpx  mx,  0x0                                                                   // 0x1618 (0x900)
  lbpx  mx,  0x0                                                                   // 0x1619 (0x900)
  lbpx  mx,  0x44                                                                  // 0x161A (0x944)
  lbpx  mx,  0x82                                                                  // 0x161B (0x982)
  lbpx  mx,  0x92                                                                  // 0x161C (0x992)
  lbpx  mx,  0x6C                                                                  // 0x161D (0x96C)
  lbpx  mx,  0x0                                                                   // 0x161E (0x900)
  retd  0x0                                                                        // 0x161F (0x100)
  
  // Large, centered 4 text
  lbpx  mx,  0x0                                                                   // 0x1620 (0x900)
  lbpx  mx,  0x0                                                                   // 0x1621 (0x900)
  lbpx  mx,  0x3C                                                                  // 0x1622 (0x93C)
  lbpx  mx,  0x22                                                                  // 0x1623 (0x922)
  lbpx  mx,  0xFE                                                                  // 0x1624 (0x9FE)
  lbpx  mx,  0x20                                                                  // 0x1625 (0x920)
  lbpx  mx,  0x0                                                                   // 0x1626 (0x900)
  retd  0x0                                                                        // 0x1627 (0x100)
  
  // Large, centered 5 text
  lbpx  mx,  0x0                                                                   // 0x1628 (0x900)
  lbpx  mx,  0x0                                                                   // 0x1629 (0x900)
  lbpx  mx,  0x9E                                                                  // 0x162A (0x99E)
  lbpx  mx,  0x92                                                                  // 0x162B (0x992)
  lbpx  mx,  0x92                                                                  // 0x162C (0x992)
  lbpx  mx,  0x62                                                                  // 0x162D (0x962)
  lbpx  mx,  0x0                                                                   // 0x162E (0x900)
  retd  0x0                                                                        // 0x162F (0x100)
  
  // Large, centered 6 text
  lbpx  mx,  0x0                                                                   // 0x1630 (0x900)
  lbpx  mx,  0x0                                                                   // 0x1631 (0x900)
  lbpx  mx,  0x7C                                                                  // 0x1632 (0x97C)
  lbpx  mx,  0x92                                                                  // 0x1633 (0x992)
  lbpx  mx,  0x92                                                                  // 0x1634 (0x992)
  lbpx  mx,  0x64                                                                  // 0x1635 (0x964)
  lbpx  mx,  0x0                                                                   // 0x1636 (0x900)
  retd  0x0                                                                        // 0x1637 (0x100)
  
  // Large, centered 7 text
  lbpx  mx,  0x0                                                                   // 0x1638 (0x900)
  lbpx  mx,  0x0                                                                   // 0x1639 (0x900)
  lbpx  mx,  0x6                                                                   // 0x163A (0x906)
  lbpx  mx,  0xE2                                                                  // 0x163B (0x9E2)
  lbpx  mx,  0x12                                                                  // 0x163C (0x912)
  lbpx  mx,  0xE                                                                   // 0x163D (0x90E)
  lbpx  mx,  0x0                                                                   // 0x163E (0x900)
  retd  0x0                                                                        // 0x163F (0x100)
  
  // Large, centered 8 text
  lbpx  mx,  0x0                                                                   // 0x1640 (0x900)
  lbpx  mx,  0x0                                                                   // 0x1641 (0x900)
  lbpx  mx,  0x6C                                                                  // 0x1642 (0x96C)
  lbpx  mx,  0x92                                                                  // 0x1643 (0x992)
  lbpx  mx,  0x92                                                                  // 0x1644 (0x992)
  lbpx  mx,  0x6C                                                                  // 0x1645 (0x96C)
  lbpx  mx,  0x0                                                                   // 0x1646 (0x900)
  retd  0x0                                                                        // 0x1647 (0x100)
  
  // Large, centered 9 text
  lbpx  mx,  0x0                                                                   // 0x1648 (0x900)
  lbpx  mx,  0x0                                                                   // 0x1649 (0x900)
  lbpx  mx,  0x4C                                                                  // 0x164A (0x94C)
  lbpx  mx,  0x92                                                                  // 0x164B (0x992)
  lbpx  mx,  0x92                                                                  // 0x164C (0x992)
  lbpx  mx,  0x7C                                                                  // 0x164D (0x97C)
  lbpx  mx,  0x0                                                                   // 0x164E (0x900)
  retd  0x0                                                                        // 0x164F (0x100)
  
  // AM vertical text
  lbpx  mx,  0x0                                                                   // 0x1650 (0x900)
  lbpx  mx,  0xEE                                                                  // 0x1651 (0x9EE)
  lbpx  mx,  0x25                                                                  // 0x1652 (0x925)
  lbpx  mx,  0xC5                                                                  // 0x1653 (0x9C5)
  lbpx  mx,  0x25                                                                  // 0x1654 (0x925)
  lbpx  mx,  0xEF                                                                  // 0x1655 (0x9EF)
  lbpx  mx,  0xEE                                                                  // 0x1656 (0x9EE)
  retd  0x0                                                                        // 0x1657 (0x100)
  
  // PM vertical text
  lbpx  mx,  0x0                                                                   // 0x1658 (0x900)
  lbpx  mx,  0xEF                                                                  // 0x1659 (0x9EF)
  lbpx  mx,  0x2F                                                                  // 0x165A (0x92F)
  lbpx  mx,  0xC5                                                                  // 0x165B (0x9C5)
  lbpx  mx,  0x25                                                                  // 0x165C (0x925)
  lbpx  mx,  0xE5                                                                  // 0x165D (0x9E5)
  lbpx  mx,  0xE2                                                                  // 0x165E (0x9E2)
  retd  0x0                                                                        // 0x165F (0x100)
  
  // S| text - Beginning of SET
  lbpx  mx,  0x0                                                                   // 0x1660 (0x900)
  lbpx  mx,  0x0                                                                   // 0x1661 (0x900)
  lbpx  mx,  0x4C                                                                  // 0x1662 (0x94C)
  lbpx  mx,  0x92                                                                  // 0x1663 (0x992)
  lbpx  mx,  0x92                                                                  // 0x1664 (0x992)
  lbpx  mx,  0x64                                                                  // 0x1665 (0x964)
  lbpx  mx,  0x0                                                                   // 0x1666 (0x900)
  retd  0xFE                                                                       // 0x1667 (0x1FE)
  
  // ET text - Ending of SET
  lbpx  mx,  0x92                                                                  // 0x1668 (0x992)
  lbpx  mx,  0x92                                                                  // 0x1669 (0x992)
  lbpx  mx,  0x0                                                                   // 0x166A (0x900)
  lbpx  mx,  0x2                                                                   // 0x166B (0x902)
  lbpx  mx,  0xFE                                                                  // 0x166C (0x9FE)
  lbpx  mx,  0x2                                                                   // 0x166D (0x902)
  lbpx  mx,  0x0                                                                   // 0x166E (0x900)
  retd  0x0                                                                        // 0x166F (0x100)
  
  // OI text
  // TODO: What is this for?
  lbpx  mx,  0x0                                                                   // 0x1670 (0x900)
  lbpx  mx,  0x3C                                                                  // 0x1671 (0x93C)
  lbpx  mx,  0x42                                                                  // 0x1672 (0x942)
  lbpx  mx,  0x42                                                                  // 0x1673 (0x942)
  lbpx  mx,  0x42                                                                  // 0x1674 (0x942)
  lbpx  mx,  0x3C                                                                  // 0x1675 (0x93C)
  lbpx  mx,  0x0                                                                   // 0x1676 (0x900)
  retd  0x7E                                                                       // 0x1677 (0x17E)
  
  // VS game result text
  lbpx  mx,  0x0                                                                   // 0x1678 (0x900)
  lbpx  mx,  0x3E                                                                  // 0x1679 (0x93E)
  lbpx  mx,  0xC0                                                                  // 0x167A (0x9C0)
  lbpx  mx,  0x3E                                                                  // 0x167B (0x93E)
  lbpx  mx,  0x0                                                                   // 0x167C (0x900)
  lbpx  mx,  0xCE                                                                  // 0x167D (0x9CE)
  lbpx  mx,  0x92                                                                  // 0x167E (0x992)
  retd  0xE6                                                                       // 0x167F (0x1E6)
  
  // Bread food, complete
  lbpx  mx,  0xC                                                                   // 0x1680 (0x90C)
  lbpx  mx,  0xF2                                                                  // 0x1681 (0x9F2)
  lbpx  mx,  0x82                                                                  // 0x1682 (0x982)
  lbpx  mx,  0x82                                                                  // 0x1683 (0x982)
  lbpx  mx,  0xF2                                                                  // 0x1684 (0x9F2)
  lbpx  mx,  0x8E                                                                  // 0x1685 (0x98E)
  lbpx  mx,  0xF2                                                                  // 0x1686 (0x9F2)
  retd  0xC                                                                        // 0x1687 (0x10C)
  
  // Bread food, first bite
  lbpx  mx,  0xC                                                                   // 0x1688 (0x90C)
  lbpx  mx,  0xF2                                                                  // 0x1689 (0x9F2)
  lbpx  mx,  0x84                                                                  // 0x168A (0x984)
  lbpx  mx,  0x88                                                                  // 0x168B (0x988)
  lbpx  mx,  0xF8                                                                  // 0x168C (0x9F8)
  lbpx  mx,  0x88                                                                  // 0x168D (0x988)
  lbpx  mx,  0xF8                                                                  // 0x168E (0x9F8)
  retd  0x0                                                                        // 0x168F (0x100)
  
  // Bread food, second bite
  lbpx  mx,  0x0                                                                   // 0x1690 (0x900)
  lbpx  mx,  0xF0                                                                  // 0x1691 (0x9F0)
  lbpx  mx,  0x90                                                                  // 0x1692 (0x990)
  lbpx  mx,  0xA0                                                                  // 0x1693 (0x9A0)
  lbpx  mx,  0xE0                                                                  // 0x1694 (0x9E0)
  lbpx  mx,  0xA0                                                                  // 0x1695 (0x9A0)
  lbpx  mx,  0xE0                                                                  // 0x1696 (0x9E0)
  retd  0x0                                                                        // 0x1697 (0x100)
  
  // Clear/empty section
  lbpx  mx,  0x0                                                                   // 0x1698 (0x900)
  lbpx  mx,  0x0                                                                   // 0x1699 (0x900)
  lbpx  mx,  0x0                                                                   // 0x169A (0x900)
  lbpx  mx,  0x0                                                                   // 0x169B (0x900)
  lbpx  mx,  0x0                                                                   // 0x169C (0x900)
  lbpx  mx,  0x0                                                                   // 0x169D (0x900)
  lbpx  mx,  0x0                                                                   // 0x169E (0x900)
  retd  0x0                                                                        // 0x169F (0x100)
  
  // Snack food, complete
  lbpx  mx,  0x4                                                                   // 0x16A0 (0x904)
  lbpx  mx,  0x6                                                                   // 0x16A1 (0x906)
  lbpx  mx,  0x3F                                                                  // 0x16A2 (0x93F)
  lbpx  mx,  0x34                                                                  // 0x16A3 (0x934)
  lbpx  mx,  0x2C                                                                  // 0x16A4 (0x92C)
  lbpx  mx,  0xFC                                                                  // 0x16A5 (0x9FC)
  lbpx  mx,  0x60                                                                  // 0x16A6 (0x960)
  retd  0x20                                                                       // 0x16A7 (0x120)
  
  // Snack food, first bite
  lbpx  mx,  0x0                                                                   // 0x16A8 (0x900)
  lbpx  mx,  0x0                                                                   // 0x16A9 (0x900)
  lbpx  mx,  0x38                                                                  // 0x16AA (0x938)
  lbpx  mx,  0x30                                                                  // 0x16AB (0x930)
  lbpx  mx,  0x28                                                                  // 0x16AC (0x928)
  lbpx  mx,  0xFC                                                                  // 0x16AD (0x9FC)
  lbpx  mx,  0x60                                                                  // 0x16AE (0x960)
  retd  0x20                                                                       // 0x16AF (0x120)
  
  // Snack food, second bite
  lbpx  mx,  0x0                                                                   // 0x16B0 (0x900)
  lbpx  mx,  0x0                                                                   // 0x16B1 (0x900)
  lbpx  mx,  0x20                                                                  // 0x16B2 (0x920)
  lbpx  mx,  0x30                                                                  // 0x16B3 (0x930)
  lbpx  mx,  0x20                                                                  // 0x16B4 (0x920)
  lbpx  mx,  0xF0                                                                  // 0x16B5 (0x9F0)
  lbpx  mx,  0x60                                                                  // 0x16B6 (0x960)
  retd  0x20                                                                       // 0x16B7 (0x120)
  
  // Most of "FF"
  // TODO: What is this for?
  lbpx  mx,  0xA                                                                   // 0x16B8 (0x90A)
  lbpx  mx,  0xA                                                                   // 0x16B9 (0x90A)
  lbpx  mx,  0x2                                                                   // 0x16BA (0x902)
  lbpx  mx,  0x0                                                                   // 0x16BB (0x900)
  lbpx  mx,  0x7E                                                                  // 0x16BC (0x97E)
  lbpx  mx,  0xA                                                                   // 0x16BD (0x90A)
  lbpx  mx,  0xA                                                                   // 0x16BE (0x90A)
  retd  0x2                                                                        // 0x16BF (0x102)
  
  // Stage 0, babytchi
  lbpx  mx,  0x0                                                                   // 0x16C0 (0x900)
  lbpx  mx,  0x3C                                                                  // 0x16C1 (0x93C)
  lbpx  mx,  0x7A                                                                  // 0x16C2 (0x97A)
  lbpx  mx,  0x6E                                                                  // 0x16C3 (0x96E)
  lbpx  mx,  0x6E                                                                  // 0x16C4 (0x96E)
  lbpx  mx,  0x7A                                                                  // 0x16C5 (0x97A)
  lbpx  mx,  0x3C                                                                  // 0x16C6 (0x93C)
  retd  0x0                                                                        // 0x16C7 (0x100)
  
  // yr lowercase, year indicator
  lbpx  mx,  0x0                                                                   // 0x16C8 (0x900)
  lbpx  mx,  0x9C                                                                  // 0x16C9 (0x99C)
  lbpx  mx,  0xA0                                                                  // 0x16CA (0x9A0)
  lbpx  mx,  0x7C                                                                  // 0x16CB (0x97C)
  lbpx  mx,  0x0                                                                   // 0x16CC (0x900)
  lbpx  mx,  0x7C                                                                  // 0x16CD (0x97C)
  lbpx  mx,  0x8                                                                   // 0x16CE (0x908)
  retd  0x4                                                                        // 0x16CF (0x104)
  
  // Scale icon
  lbpx  mx,  0x0                                                                   // 0x16D0 (0x900)
  lbpx  mx,  0x86                                                                  // 0x16D1 (0x986)
  lbpx  mx,  0xF4                                                                  // 0x16D2 (0x9F4)
  lbpx  mx,  0x94                                                                  // 0x16D3 (0x994)
  lbpx  mx,  0xDC                                                                  // 0x16D4 (0x9DC)
  lbpx  mx,  0x94                                                                  // 0x16D5 (0x994)
  lbpx  mx,  0xF4                                                                  // 0x16D6 (0x9F4)
  retd  0x86                                                                       // 0x16D7 (0x186)
  
  // OZ uppercase, weight indicator
  lbpx  mx,  0x0                                                                   // 0x16D8 (0x900)
  lbpx  mx,  0xFC                                                                  // 0x16D9 (0x9FC)
  lbpx  mx,  0x84                                                                  // 0x16DA (0x984)
  lbpx  mx,  0xFC                                                                  // 0x16DB (0x9FC)
  lbpx  mx,  0x0                                                                   // 0x16DC (0x900)
  lbpx  mx,  0xC4                                                                  // 0x16DD (0x9C4)
  lbpx  mx,  0xB4                                                                  // 0x16DE (0x9B4)
  retd  0x8C                                                                       // 0x16DF (0x18C)
  
  // Filled in heart, satisfied
  lbpx  mx,  0x1C                                                                  // 0x16E0 (0x91C)
  lbpx  mx,  0x32                                                                  // 0x16E1 (0x932)
  lbpx  mx,  0x7E                                                                  // 0x16E2 (0x97E)
  lbpx  mx,  0xFC                                                                  // 0x16E3 (0x9FC)
  lbpx  mx,  0x7E                                                                  // 0x16E4 (0x97E)
  lbpx  mx,  0x3E                                                                  // 0x16E5 (0x93E)
  lbpx  mx,  0x1C                                                                  // 0x16E6 (0x91C)
  retd  0x0                                                                        // 0x16E7 (0x100)
  
  // Empty heart, unsatisfied
  lbpx  mx,  0x1C                                                                  // 0x16E8 (0x91C)
  lbpx  mx,  0x22                                                                  // 0x16E9 (0x922)
  lbpx  mx,  0x42                                                                  // 0x16EA (0x942)
  lbpx  mx,  0x84                                                                  // 0x16EB (0x984)
  lbpx  mx,  0x42                                                                  // 0x16EC (0x942)
  lbpx  mx,  0x22                                                                  // 0x16ED (0x922)
  lbpx  mx,  0x1C                                                                  // 0x16EE (0x91C)
  retd  0x0                                                                        // 0x16EF (0x100)
  
  // Stinky poop, right arrows
  lbpx  mx,  0x5                                                                   // 0x16F0 (0x905)
  lbpx  mx,  0xC2                                                                  // 0x16F1 (0x9C2)
  lbpx  mx,  0xA0                                                                  // 0x16F2 (0x9A0)
  lbpx  mx,  0xF8                                                                  // 0x16F3 (0x9F8)
  lbpx  mx,  0xD0                                                                  // 0x16F4 (0x9D0)
  lbpx  mx,  0xE0                                                                  // 0x16F5 (0x9E0)
  lbpx  mx,  0xCA                                                                  // 0x16F6 (0x9CA)
  retd  0x4                                                                        // 0x16F7 (0x104)
  
  // Stinky poop, left arrows
  lbpx  mx,  0x4                                                                   // 0x16F8 (0x904)
  lbpx  mx,  0xCA                                                                  // 0x16F9 (0x9CA)
  lbpx  mx,  0xE0                                                                  // 0x16FA (0x9E0)
  lbpx  mx,  0xF8                                                                  // 0x16FB (0x9F8)
  lbpx  mx,  0xD0                                                                  // 0x16FC (0x9D0)
  lbpx  mx,  0xA0                                                                  // 0x16FD (0x9A0)
  lbpx  mx,  0xC2                                                                  // 0x16FE (0x9C2)
  retd  0x5                                                                        // 0x16FF (0x105)
  
  // Big Z with black background, sleeping
  lbpx  mx,  0xFF                                                                  // 0x1700 (0x9FF)
  lbpx  mx,  0x3B                                                                  // 0x1701 (0x93B)
  lbpx  mx,  0x5B                                                                  // 0x1702 (0x95B)
  lbpx  mx,  0x6B                                                                  // 0x1703 (0x96B)
  lbpx  mx,  0x73                                                                  // 0x1704 (0x973)
  lbpx  mx,  0xFF                                                                  // 0x1705 (0x9FF)
  lbpx  mx,  0xFF                                                                  // 0x1706 (0x9FF)
  retd  0xFF                                                                       // 0x1707 (0x1FF)
  
  // Smaller Z with dots and black background, sleeping
  lbpx  mx,  0xDF                                                                  // 0x1708 (0x9DF)
  lbpx  mx,  0xFF                                                                  // 0x1709 (0x9FF)
  lbpx  mx,  0xEF                                                                  // 0x170A (0x9EF)
  lbpx  mx,  0xFF                                                                  // 0x170B (0x9FF)
  lbpx  mx,  0xE6                                                                  // 0x170C (0x9E6)
  lbpx  mx,  0xEA                                                                  // 0x170D (0x9EA)
  lbpx  mx,  0xEC                                                                  // 0x170E (0x9EC)
  retd  0xFF                                                                       // 0x170F (0x1FF)
  
  // Sickness skull
  lbpx  mx,  0x0                                                                   // 0x1710 (0x900)
  lbpx  mx,  0x3C                                                                  // 0x1711 (0x93C)
  lbpx  mx,  0xF6                                                                  // 0x1712 (0x9F6)
  lbpx  mx,  0x76                                                                  // 0x1713 (0x976)
  lbpx  mx,  0xDE                                                                  // 0x1714 (0x9DE)
  lbpx  mx,  0x76                                                                  // 0x1715 (0x976)
  lbpx  mx,  0xF6                                                                  // 0x1716 (0x9F6)
  retd  0x3C                                                                       // 0x1717 (0x13C)
  
  // Success sparkle
  lbpx  mx,  0x8                                                                   // 0x1718 (0x908)
  lbpx  mx,  0x42                                                                  // 0x1719 (0x942)
  lbpx  mx,  0x18                                                                  // 0x171A (0x918)
  lbpx  mx,  0x25                                                                  // 0x171B (0x925)
  lbpx  mx,  0xA4                                                                  // 0x171C (0x9A4)
  lbpx  mx,  0x18                                                                  // 0x171D (0x918)
  lbpx  mx,  0x42                                                                  // 0x171E (0x942)
  retd  0x10                                                                       // 0x171F (0x110)
  
  // Angry ticks
  lbpx  mx,  0x0                                                                   // 0x1720 (0x900)
  lbpx  mx,  0x40                                                                  // 0x1721 (0x940)
  lbpx  mx,  0x0                                                                   // 0x1722 (0x900)
  lbpx  mx,  0xC                                                                   // 0x1723 (0x90C)
  lbpx  mx,  0xF                                                                   // 0x1724 (0x90F)
  lbpx  mx,  0x1F                                                                  // 0x1725 (0x91F)
  lbpx  mx,  0x1E                                                                  // 0x1726 (0x91E)
  retd  0x6                                                                        // 0x1727 (0x106)
  
  // Smaller ticks
  // TODO: What is this used for?
  lbpx  mx,  0x0                                                                   // 0x1728 (0x900)
  lbpx  mx,  0x0                                                                   // 0x1729 (0x900)
  lbpx  mx,  0x20                                                                  // 0x172A (0x920)
  lbpx  mx,  0x18                                                                  // 0x172B (0x918)
  lbpx  mx,  0x18                                                                  // 0x172C (0x918)
  lbpx  mx,  0x0                                                                   // 0x172D (0x900)
  lbpx  mx,  0x0                                                                   // 0x172E (0x900)
  retd  0x0                                                                        // 0x172F (0x100)
  
  // Left filled in arrow
  lbpx  mx,  0x0                                                                   // 0x1730 (0x900)
  lbpx  mx,  0x10                                                                  // 0x1731 (0x910)
  lbpx  mx,  0x38                                                                  // 0x1732 (0x938)
  lbpx  mx,  0x7C                                                                  // 0x1733 (0x97C)
  lbpx  mx,  0xFE                                                                  // 0x1734 (0x9FE)
  lbpx  mx,  0x38                                                                  // 0x1735 (0x938)
  lbpx  mx,  0x38                                                                  // 0x1736 (0x938)
  retd  0x0                                                                        // 0x1737 (0x100)
  
  // Right filled in arrow
  lbpx  mx,  0x0                                                                   // 0x1738 (0x900)
  lbpx  mx,  0x38                                                                  // 0x1739 (0x938)
  lbpx  mx,  0x38                                                                  // 0x173A (0x938)
  lbpx  mx,  0xFE                                                                  // 0x173B (0x9FE)
  lbpx  mx,  0x7C                                                                  // 0x173C (0x97C)
  lbpx  mx,  0x38                                                                  // 0x173D (0x938)
  lbpx  mx,  0x10                                                                  // 0x173E (0x910)
  retd  0x0                                                                        // 0x173F (0x100)
  
  // Me cut off. Start of Meal
  lbpx  mx,  0x7E                                                                  // 0x1740 (0x97E)
  lbpx  mx,  0x2                                                                   // 0x1741 (0x902)
  lbpx  mx,  0x3C                                                                  // 0x1742 (0x93C)
  lbpx  mx,  0x2                                                                   // 0x1743 (0x902)
  lbpx  mx,  0x7E                                                                  // 0x1744 (0x97E)
  lbpx  mx,  0x0                                                                   // 0x1745 (0x900)
  lbpx  mx,  0x38                                                                  // 0x1746 (0x938)
  retd  0x54                                                                       // 0x1747 (0x154)
  
  // ea cut off. Middle of Meal
  lbpx  mx,  0x54                                                                  // 0x1748 (0x954)
  lbpx  mx,  0x58                                                                  // 0x1749 (0x958)
  lbpx  mx,  0x0                                                                   // 0x174A (0x900)
  lbpx  mx,  0x30                                                                  // 0x174B (0x930)
  lbpx  mx,  0x54                                                                  // 0x174C (0x954)
  lbpx  mx,  0x54                                                                  // 0x174D (0x954)
  lbpx  mx,  0x3C                                                                  // 0x174E (0x93C)
  retd  0x40                                                                       // 0x174F (0x140)
  
  // l. end of Meal
  lbpx  mx,  0x0                                                                   // 0x1750 (0x900)
  lbpx  mx,  0x7E                                                                  // 0x1751 (0x97E)
  lbpx  mx,  0x0                                                                   // 0x1752 (0x900)
  lbpx  mx,  0x0                                                                   // 0x1753 (0x900)
  lbpx  mx,  0x0                                                                   // 0x1754 (0x900)
  lbpx  mx,  0x0                                                                   // 0x1755 (0x900)
  lbpx  mx,  0x0                                                                   // 0x1756 (0x900)
  retd  0x0                                                                        // 0x1757 (0x100)
  
  // Sn cut off. Start of Snack
  lbpx  mx,  0x26                                                                  // 0x1758 (0x926)
  lbpx  mx,  0x49                                                                  // 0x1759 (0x949)
  lbpx  mx,  0x49                                                                  // 0x175A (0x949)
  lbpx  mx,  0x32                                                                  // 0x175B (0x932)
  lbpx  mx,  0x0                                                                   // 0x175C (0x900)
  lbpx  mx,  0x7C                                                                  // 0x175D (0x97C)
  lbpx  mx,  0x4                                                                   // 0x175E (0x904)
  retd  0x4                                                                        // 0x175F (0x104)
  
  // na cut off. Middle of Snack
  lbpx  mx,  0x7C                                                                  // 0x1760 (0x97C)
  lbpx  mx,  0x0                                                                   // 0x1761 (0x900)
  lbpx  mx,  0x30                                                                  // 0x1762 (0x930)
  lbpx  mx,  0x54                                                                  // 0x1763 (0x954)
  lbpx  mx,  0x54                                                                  // 0x1764 (0x954)
  lbpx  mx,  0x3C                                                                  // 0x1765 (0x93C)
  lbpx  mx,  0x40                                                                  // 0x1766 (0x940)
  retd  0x38                                                                       // 0x1767 (0x138)
  
  // ck cut off. End of Snack
  lbpx  mx,  0x44                                                                  // 0x1768 (0x944)
  lbpx  mx,  0x44                                                                  // 0x1769 (0x944)
  lbpx  mx,  0x28                                                                  // 0x176A (0x928)
  lbpx  mx,  0x0                                                                   // 0x176B (0x900)
  lbpx  mx,  0x7F                                                                  // 0x176C (0x97F)
  lbpx  mx,  0x10                                                                  // 0x176D (0x910)
  lbpx  mx,  0x68                                                                  // 0x176E (0x968)
  retd  0x0                                                                        // 0x176F (0x100)
  
  // Hu. Start of Hungry
  lbpx  mx,  0x7F                                                                  // 0x1770 (0x97F)
  lbpx  mx,  0x8                                                                   // 0x1771 (0x908)
  lbpx  mx,  0x8                                                                   // 0x1772 (0x908)
  lbpx  mx,  0x7F                                                                  // 0x1773 (0x97F)
  lbpx  mx,  0x0                                                                   // 0x1774 (0x900)
  lbpx  mx,  0x7C                                                                  // 0x1775 (0x97C)
  lbpx  mx,  0x40                                                                  // 0x1776 (0x940)
  retd  0x7C                                                                       // 0x1777 (0x17C)
  
  // ng. Middle of Hungry
  lbpx  mx,  0x0                                                                   // 0x1778 (0x900)
  lbpx  mx,  0x7C                                                                  // 0x1779 (0x97C)
  lbpx  mx,  0x4                                                                   // 0x177A (0x904)
  lbpx  mx,  0x7C                                                                  // 0x177B (0x97C)
  lbpx  mx,  0x0                                                                   // 0x177C (0x900)
  lbpx  mx,  0xBC                                                                  // 0x177D (0x9BC)
  lbpx  mx,  0xA4                                                                  // 0x177E (0x9A4)
  retd  0xFC                                                                       // 0x177F (0x1FC)
  
  // ry. End of Hungry
  lbpx  mx,  0x0                                                                   // 0x1780 (0x900)
  lbpx  mx,  0x7C                                                                  // 0x1781 (0x97C)
  lbpx  mx,  0x8                                                                   // 0x1782 (0x908)
  lbpx  mx,  0x4                                                                   // 0x1783 (0x904)
  lbpx  mx,  0x0                                                                   // 0x1784 (0x900)
  lbpx  mx,  0x9C                                                                  // 0x1785 (0x99C)
  lbpx  mx,  0xA0                                                                  // 0x1786 (0x9A0)
  retd  0x7C                                                                       // 0x1787 (0x17C)
  
  // Ha cut off. Start of Happy
  lbpx  mx,  0x0                                                                   // 0x1788 (0x900)
  lbpx  mx,  0x7F                                                                  // 0x1789 (0x97F)
  lbpx  mx,  0x8                                                                   // 0x178A (0x908)
  lbpx  mx,  0x8                                                                   // 0x178B (0x908)
  lbpx  mx,  0x7F                                                                  // 0x178C (0x97F)
  lbpx  mx,  0x0                                                                   // 0x178D (0x900)
  lbpx  mx,  0x30                                                                  // 0x178E (0x930)
  retd  0x54                                                                       // 0x178F (0x154)
  
  // ap cut off. Middle of Happy
  lbpx  mx,  0x54                                                                  // 0x1790 (0x954)
  lbpx  mx,  0x3C                                                                  // 0x1791 (0x93C)
  lbpx  mx,  0x40                                                                  // 0x1792 (0x940)
  lbpx  mx,  0x0                                                                   // 0x1793 (0x900)
  lbpx  mx,  0xFC                                                                  // 0x1794 (0x9FC)
  lbpx  mx,  0x24                                                                  // 0x1795 (0x924)
  lbpx  mx,  0x3C                                                                  // 0x1796 (0x93C)
  retd  0x0                                                                        // 0x1797 (0x100)
  
  // py. End of Happy
  lbpx  mx,  0xFC                                                                  // 0x1798 (0x9FC)
  lbpx  mx,  0x24                                                                  // 0x1799 (0x924)
  lbpx  mx,  0x3C                                                                  // 0x179A (0x93C)
  lbpx  mx,  0x0                                                                   // 0x179B (0x900)
  lbpx  mx,  0x9C                                                                  // 0x179C (0x99C)
  lbpx  mx,  0xA0                                                                  // 0x179D (0x9A0)
  lbpx  mx,  0x7C                                                                  // 0x179E (0x97C)
  retd  0x0                                                                        // 0x179F (0x100)
  
  // Di. Start of Dicipline
  lbpx  mx,  0x0                                                                   // 0x17A0 (0x900)
  lbpx  mx,  0x7F                                                                  // 0x17A1 (0x97F)
  lbpx  mx,  0x41                                                                  // 0x17A2 (0x941)
  lbpx  mx,  0x41                                                                  // 0x17A3 (0x941)
  lbpx  mx,  0x3E                                                                  // 0x17A4 (0x93E)
  lbpx  mx,  0x0                                                                   // 0x17A5 (0x900)
  lbpx  mx,  0x74                                                                  // 0x17A6 (0x974)
  retd  0x0                                                                        // 0x17A7 (0x100)
  
  // sci. Middle of Dicipline
  lbpx  mx,  0x5C                                                                  // 0x17A8 (0x95C)
  lbpx  mx,  0x74                                                                  // 0x17A9 (0x974)
  lbpx  mx,  0x0                                                                   // 0x17AA (0x900)
  lbpx  mx,  0x7C                                                                  // 0x17AB (0x97C)
  lbpx  mx,  0x44                                                                  // 0x17AC (0x944)
  lbpx  mx,  0x0                                                                   // 0x17AD (0x900)
  lbpx  mx,  0x74                                                                  // 0x17AE (0x974)
  retd  0x0                                                                        // 0x17AF (0x100)
  
  // pli. Middle of Dicipline
  lbpx  mx,  0xFC                                                                  // 0x17B0 (0x9FC)
  lbpx  mx,  0x24                                                                  // 0x17B1 (0x924)
  lbpx  mx,  0x3C                                                                  // 0x17B2 (0x93C)
  lbpx  mx,  0x0                                                                   // 0x17B3 (0x900)
  lbpx  mx,  0x7F                                                                  // 0x17B4 (0x97F)
  lbpx  mx,  0x0                                                                   // 0x17B5 (0x900)
  lbpx  mx,  0x74                                                                  // 0x17B6 (0x974)
  retd  0x0                                                                        // 0x17B7 (0x100)
  
  // ne. End of Dicipline
  lbpx  mx,  0x7C                                                                  // 0x17B8 (0x97C)
  lbpx  mx,  0x4                                                                   // 0x17B9 (0x904)
  lbpx  mx,  0x7C                                                                  // 0x17BA (0x97C)
  lbpx  mx,  0x0                                                                   // 0x17BB (0x900)
  lbpx  mx,  0x7C                                                                  // 0x17BC (0x97C)
  lbpx  mx,  0x54                                                                  // 0x17BD (0x954)
  lbpx  mx,  0x5C                                                                  // 0x17BE (0x95C)
  retd  0x0                                                                        // 0x17BF (0x100)
  
  // Wide O
  // TODO: What is this used for?
  lbpx  mx,  0x0                                                                   // 0x17C0 (0x900)
  lbpx  mx,  0x3C                                                                  // 0x17C1 (0x93C)
  lbpx  mx,  0x42                                                                  // 0x17C2 (0x942)
  lbpx  mx,  0x42                                                                  // 0x17C3 (0x942)
  lbpx  mx,  0x42                                                                  // 0x17C4 (0x942)
  lbpx  mx,  0x3C                                                                  // 0x17C5 (0x93C)
  lbpx  mx,  0x0                                                                   // 0x17C6 (0x900)
  retd  0x0                                                                        // 0x17C7 (0x100)
  
  // Wide N
  // TODO: What is this used for?
  lbpx  mx,  0x0                                                                   // 0x17C8 (0x900)
  lbpx  mx,  0x7E                                                                  // 0x17C9 (0x97E)
  lbpx  mx,  0x2                                                                   // 0x17CA (0x902)
  lbpx  mx,  0xC                                                                   // 0x17CB (0x90C)
  lbpx  mx,  0x30                                                                  // 0x17CC (0x930)
  lbpx  mx,  0x40                                                                  // 0x17CD (0x940)
  lbpx  mx,  0x7E                                                                  // 0x17CE (0x97E)
  retd  0x0                                                                        // 0x17CF (0x100)
  
  // Big Z with clear background. Sleeping
  lbpx  mx,  0x0                                                                   // 0x17D0 (0x900)
  lbpx  mx,  0xC4                                                                  // 0x17D1 (0x9C4)
  lbpx  mx,  0xA4                                                                  // 0x17D2 (0x9A4)
  lbpx  mx,  0x94                                                                  // 0x17D3 (0x994)
  lbpx  mx,  0x8C                                                                  // 0x17D4 (0x98C)
  lbpx  mx,  0x0                                                                   // 0x17D5 (0x900)
  lbpx  mx,  0x0                                                                   // 0x17D6 (0x900)
  retd  0x0                                                                        // 0x17D7 (0x100)
  
  // Little Z with dots and clear background. Sleeping
  lbpx  mx,  0x20                                                                  // 0x17D8 (0x920)
  lbpx  mx,  0x0                                                                   // 0x17D9 (0x900)
  lbpx  mx,  0x10                                                                  // 0x17DA (0x910)
  lbpx  mx,  0x0                                                                   // 0x17DB (0x900)
  lbpx  mx,  0x19                                                                  // 0x17DC (0x919)
  lbpx  mx,  0x15                                                                  // 0x17DD (0x915)
  lbpx  mx,  0x13                                                                  // 0x17DE (0x913)
  retd  0x0                                                                        // 0x17DF (0x100)
  
  // The remander of these are blank
  lbpx  mx,  0x0                                                                   // 0x17E0 (0x900)
  lbpx  mx,  0x0                                                                   // 0x17E1 (0x900)
  lbpx  mx,  0x0                                                                   // 0x17E2 (0x900)
  lbpx  mx,  0x0                                                                   // 0x17E3 (0x900)
  lbpx  mx,  0x0                                                                   // 0x17E4 (0x900)
  lbpx  mx,  0x0                                                                   // 0x17E5 (0x900)
  lbpx  mx,  0x0                                                                   // 0x17E6 (0x900)
  retd  0x0                                                                        // 0x17E7 (0x100)
  lbpx  mx,  0x0                                                                   // 0x17E8 (0x900)
  lbpx  mx,  0x0                                                                   // 0x17E9 (0x900)
  lbpx  mx,  0x0                                                                   // 0x17EA (0x900)
  lbpx  mx,  0x0                                                                   // 0x17EB (0x900)
  lbpx  mx,  0x0                                                                   // 0x17EC (0x900)
  lbpx  mx,  0x0                                                                   // 0x17ED (0x900)
  lbpx  mx,  0x0                                                                   // 0x17EE (0x900)
  retd  0x0                                                                        // 0x17EF (0x100)
  lbpx  mx,  0x0                                                                   // 0x17F0 (0x900)
  lbpx  mx,  0x0                                                                   // 0x17F1 (0x900)
  lbpx  mx,  0x0                                                                   // 0x17F2 (0x900)
  lbpx  mx,  0x0                                                                   // 0x17F3 (0x900)
  lbpx  mx,  0x0                                                                   // 0x17F4 (0x900)
  lbpx  mx,  0x0                                                                   // 0x17F5 (0x900)
  lbpx  mx,  0x0                                                                   // 0x17F6 (0x900)
  retd  0x0                                                                        // 0x17F7 (0x100)
  lbpx  mx,  0x0                                                                   // 0x17F8 (0x900)
  lbpx  mx,  0x0                                                                   // 0x17F9 (0x900)
  lbpx  mx,  0x0                                                                   // 0x17FA (0x900)
  lbpx  mx,  0x0                                                                   // 0x17FB (0x900)
  lbpx  mx,  0x0                                                                   // 0x17FC (0x900)
  lbpx  mx,  0x0                                                                   // 0x17FD (0x900)
  lbpx  mx,  0x0                                                                   // 0x17FE (0x900)
  retd  0x0                                                                        // 0x17FF (0x100)
