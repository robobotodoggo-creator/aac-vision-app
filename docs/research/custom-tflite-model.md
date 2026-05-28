# Custom AAC-Trained TFLite Vision Model

**Date:** 2026-05-28
**Author:** Claude Opus 4.6
**Status:** Research complete — actionable when training infrastructure and device are available

## Problem

ML Kit's default image labeler recognizes ~400 general-purpose classes (animals, vehicles, food, sports, landmarks, etc.). These classes were chosen for consumer photography, not for AAC users. The result is a mismatch: the model confidently labels "brown bear" or "skyscraper" but cannot distinguish a **wheelchair** from a **walker**, a **medication bottle** from a generic "bottle," or a **communication board** from a "poster."

For stroke survivors using this app at home or in rehabilitation, the objects that matter most — adaptive equipment, therapy tools, specific foods, personal items — are either absent from the label set or collapsed into overly broad categories.

### What ML Kit's default model CAN detect (relevant to AAC)

From the ~400 default labels, the ones useful for AAC context mapping are roughly:

| Category | Useful labels |
|----------|--------------|
| Food/drink | Food, Fruit, Vegetable, Bread, Pizza, Cake, Dessert, Snack, Coffee, Juice, Fast food, Sushi, Cookie |
| Animals | Cat, Dog, Bird, Bear, Horse, Duck, Insect, Fish |
| People | Person, Baby, Selfie, Crowd |
| Furniture | Chair, Couch, Desk, Bed, Pillow, Curtain |
| Transport | Car, Bus, Boat, Bicycle, Motorcycle, Train, Helicopter, Airplane |
| Electronics | Computer, Mobile phone, Television |
| Clothing | Shoe, Hat, Jacket, Shorts, Scarf, Jeans |
| Places | Bathroom, Bedroom, Kitchen (inferred), School, Church |
| Misc | Toy, Stuffed toy, Book, Flower, Plant, Umbrella, Glasses, Sunglasses |

**~50 of ~400 labels** are directly useful for AAC context. The other ~350 labels (Bonfire, Rafting, Bullfighting, Circus, Prom, Casino, Badminton, Wakeboarding, etc.) are irrelevant noise for a stroke survivor at home.

### What ML Kit's default model CANNOT detect (critical for AAC)

Objects that matter for AAC users but are **absent** from ML Kit's 400-class model:

- **Mobility aids:** wheelchair, walker/rollator, crutch, cane, grab bar, transfer board
- **Medical equipment:** oxygen tank/concentrator, nebulizer, blood pressure monitor, pulse oximeter, hospital bed, IV stand, catheter bag, suction machine
- **Medication:** pill bottle, pill organizer, syringe (present but medical context missing), inhaler, eye drops, topical cream tube
- **Therapy tools:** communication board, eye-gaze device, switch access device, adaptive utensils, therapy putty, resistance band
- **Personal care:** adult diaper/incontinence pad, hearing aid, dentures, compression stockings, shower chair
- **Home environment specifics:** call button/nurse call, bed rail, ramp, stair lift, raised toilet seat, commode
- **Specific food/drink packaging:** ensure/boost nutrition shake, applesauce pouch, thickened liquid, sippy cup with handles, adaptive cup

This is the gap a custom model would close.

## Phase 1: AAC-Relevant Class Catalog (~500 classes)

Below is a catalog of ~500 classes organized into AAC-relevant domains. Classes marked with ★ are **high-priority** (directly trigger AAC suggestions). Classes marked with ◆ are already in OpenImages V7's 600-class bounding box set. Classes marked with ● are already in ML Kit's default ~400-class set.

### 1. Mobility & Assistive Devices (45 classes)

| # | Class | Notes |
|---|-------|-------|
| 1 | ★ Wheelchair | ◆ OpenImages |
| 2 | ★ Walker / Rollator | — |
| 3 | ★ Crutch | ◆ OpenImages |
| 4 | ★ Cane / Walking stick | — |
| 5 | ★ Grab bar | — |
| 6 | ★ Transfer board | — |
| 7 | ★ Stair lift | — |
| 8 | ★ Wheelchair ramp | — |
| 9 | ★ Mobility scooter | — |
| 10 | ★ Prosthetic limb | — |
| 11 | ★ Orthotic brace | — |
| 12 | ★ AFO (ankle-foot orthosis) | — |
| 13 | ★ Knee brace | — |
| 14 | ★ Sling (arm) | — |
| 15 | ★ Neck brace / Cervical collar | — |
| 16 | ★ Raised toilet seat | — |
| 17 | ★ Commode | — |
| 18 | ★ Shower chair / Bath bench | — |
| 19 | ★ Bed rail | — |
| 20 | ★ Hospital bed | — |
| 21 | Stretcher | ◆ OpenImages |
| 22 | Wheelchair cushion | — |
| 23 | Standing frame | — |
| 24 | Gait trainer | — |
| 25 | Hoyer lift / Patient lift | — |
| 26 | Reacher / Grabber tool | — |
| 27 | Long-handled shoehorn | — |
| 28 | Sock aid | — |
| 29 | Button hook | — |
| 30 | Elastic shoelaces | — |
| 31 | Non-slip mat | — |
| 32 | Swivel cushion | — |
| 33 | Sliding board | — |
| 34 | Weighted blanket | — |
| 35 | Positioning wedge | — |
| 36 | ★ Call button / Nurse call | — |
| 37 | Adapted steering wheel | — |
| 38 | Hand controls (vehicle) | — |
| 39 | Transfer belt / Gait belt | — |
| 40 | Anti-tip wheels | — |
| 41 | Wheelchair tray | — |
| 42 | Wheelchair bag | — |
| 43 | Power wheelchair joystick | — |
| 44 | Wheelchair footrest | — |
| 45 | Wheelchair headrest | — |

### 2. Medical Equipment & Health (50 classes)

| # | Class | Notes |
|---|-------|-------|
| 46 | ★ Oxygen tank | — |
| 47 | ★ Oxygen concentrator | — |
| 48 | ★ Nasal cannula | — |
| 49 | ★ Nebulizer | — |
| 50 | ★ Blood pressure monitor | — |
| 51 | ★ Pulse oximeter | — |
| 52 | ★ Thermometer | — |
| 53 | ★ IV stand / IV bag | — |
| 54 | ★ Catheter bag | — |
| 55 | ★ Suction machine | — |
| 56 | ★ CPAP machine | — |
| 57 | ★ Hearing aid | — |
| 58 | ★ Stethoscope | ◆ OpenImages |
| 59 | ★ Pill bottle | — |
| 60 | ★ Pill organizer (weekly) | — |
| 61 | ★ Syringe | ◆ OpenImages |
| 62 | ★ Inhaler | — |
| 63 | ★ Eye drops bottle | — |
| 64 | ★ Topical cream tube | — |
| 65 | ★ Band-aid / Adhesive bandage | ◆ OpenImages |
| 66 | ★ Bandage / Gauze | — |
| 67 | ★ Ice pack | — |
| 68 | ★ Heating pad | — |
| 69 | ★ Hot water bottle | — |
| 70 | ★ Dentures | — |
| 71 | ★ Compression stockings | — |
| 72 | Medical gloves (latex/nitrile) | ◆ OpenImages (Glove) |
| 73 | Face mask (surgical) | — |
| 74 | Hand sanitizer | — |
| 75 | Glucose meter | — |
| 76 | Insulin pen | — |
| 77 | EpiPen | — |
| 78 | Wound dressing | — |
| 79 | Medical tape | ◆ OpenImages (Adhesive tape) |
| 80 | Cotton swab | — |
| 81 | Alcohol wipe | — |
| 82 | Sharps container | — |
| 83 | Bedpan | — |
| 84 | Urinal (medical) | — |
| 85 | Disposable underpad | — |
| 86 | Adult diaper / Incontinence pad | — |
| 87 | Wheelchair scale | — |
| 88 | Hospital gown | — |
| 89 | Medical ID bracelet | — |
| 90 | Reachers for medication | — |
| 91 | Pill cutter | — |
| 92 | Pill crusher | — |
| 93 | Medicine cup | — |
| 94 | Nebulizer mask | — |
| 95 | Tracheostomy tube | — |

### 3. AAC & Communication Devices (25 classes)

| # | Class | Notes |
|---|-------|-------|
| 96 | ★ Communication board (low-tech) | — |
| 97 | ★ Eye-gaze device | — |
| 98 | ★ Switch access device | — |
| 99 | ★ Speech-generating device (SGD) | — |
| 100 | ★ Big button switch | — |
| 101 | ★ Head pointer | — |
| 102 | ★ Mouth stick | — |
| 103 | ★ Picture exchange cards (PECS) | — |
| 104 | ★ Communication book | — |
| 105 | ★ Letter board | — |
| 106 | ★ Tablet with AAC app | — |
| 107 | ★ Adapted keyboard | — |
| 108 | ★ Trackball mouse | — |
| 109 | ★ Joystick controller | — |
| 110 | Touch screen stylus | — |
| 111 | Adaptive pen/pencil grip | — |
| 112 | Mounting arm (device) | — |
| 113 | Bluetooth speaker (AAC output) | — |
| 114 | Headband pointer | — |
| 115 | Sip-and-puff device | — |
| 116 | Proximity sensor switch | — |
| 117 | Tilt switch | — |
| 118 | Voice amplifier | — |
| 119 | FM system (hearing) | — |
| 120 | Visual timer | — |

### 4. Therapy & Rehabilitation (30 classes)

| # | Class | Notes |
|---|-------|-------|
| 121 | ★ Therapy putty | — |
| 122 | ★ Resistance band | — |
| 123 | ★ Hand exerciser / Grip strengthener | — |
| 124 | ★ Therapy ball (exercise ball) | — |
| 125 | ★ Foam roller | — |
| 126 | ★ Balance board | — |
| 127 | ★ TENS unit | — |
| 128 | ★ Parallel bars (rehab) | — |
| 129 | ★ Peg board (OT) | — |
| 130 | ★ Stacking cones (OT) | — |
| 131 | Wrist weight | — |
| 132 | Ankle weight | — |
| 133 | Therapy mirror | — |
| 134 | Arm bike / Upper body ergometer | — |
| 135 | Pedal exerciser | — |
| 136 | Hand splint | — |
| 137 | Finger extension splint | — |
| 138 | Thumb spica splint | — |
| 139 | Kinesiology tape | — |
| 140 | Muscle stimulator | — |
| 141 | Paraffin wax bath | — |
| 142 | Cold therapy unit | — |
| 143 | Range-of-motion device | — |
| 144 | Shoulder pulley | — |
| 145 | Coordination board | — |
| 146 | Cognitive therapy cards | — |
| 147 | Memory game (rehab) | — |
| 148 | Word-finding cards | — |
| 149 | Sequencing cards | — |
| 150 | Mirror box (stroke rehab) | — |

### 5. Adapted Eating & Drinking (35 classes)

| # | Class | Notes |
|---|-------|-------|
| 151 | ★ Adaptive spoon (weighted/angled) | — |
| 152 | ★ Adaptive fork | — |
| 153 | ★ Adaptive knife (rocker knife) | — |
| 154 | ★ Sippy cup with handles | — |
| 155 | ★ No-spill cup | — |
| 156 | ★ Thickened liquid | — |
| 157 | ★ Nutrition shake (Ensure/Boost) | — |
| 158 | ★ Applesauce pouch | — |
| 159 | ★ Plate guard / Food bumper | — |
| 160 | ★ Non-slip placemat | — |
| 161 | ★ Divided plate | — |
| 162 | ★ Scoop plate | — |
| 163 | ★ Straw (bendy/reusable) | ◆ OpenImages (Drinking straw) |
| 164 | ★ Feeding tube (NG tube) | — |
| 165 | ★ PEG tube | — |
| 166 | Cup holder (wheelchair mount) | — |
| 167 | Dycem mat | — |
| 168 | Universal cuff (utensil holder) | — |
| 169 | Built-up handle utensil | — |
| 170 | Long-handled spoon | — |
| 171 | Swivel spoon | — |
| 172 | One-handed cutting board | — |
| 173 | Jar opener (adaptive) | — |
| 174 | Electric can opener | ◆ OpenImages (Can opener) |
| 175 | Kettle tipper | — |
| 176 | Cup with lid | — |
| 177 | Insulated mug | — |
| 178 | Bib (adult) | — |
| 179 | Food thickener powder | — |
| 180 | Enteral feeding pump | — |
| 181 | Bolus syringe (feeding) | — |
| 182 | Suction plate | — |
| 183 | Angled cup | — |
| 184 | Nose cutout cup | — |
| 185 | Two-handled cup | — |

### 6. Common Household Objects (expanded for AAC context) (80 classes)

These are objects that ML Kit partially covers but where finer granularity improves AAC suggestions:

| # | Class | Notes |
|---|-------|-------|
| 186 | ★ Light switch | ◆ OpenImages |
| 187 | ★ Doorbell | — |
| 188 | ★ Door handle | ◆ OpenImages |
| 189 | ★ Window | ◆ OpenImages |
| 190 | ★ Thermostat | — |
| 191 | ★ Remote control | ◆ OpenImages |
| 192 | ★ Telephone (landline) | ◆ OpenImages |
| 193 | ★ Alarm clock | ◆ OpenImages |
| 194 | ★ Wall clock | ◆ OpenImages |
| 195 | ★ Calendar | — |
| 196 | ★ Whiteboard | ◆ OpenImages, ● ML Kit |
| 197 | ★ Lamp | ◆ OpenImages |
| 198 | ★ Fan (ceiling/standing) | ◆ OpenImages (Mechanical fan, Ceiling fan) |
| 199 | ★ Air conditioner | — |
| 200 | ★ Heater | ◆ OpenImages |
| 201 | ★ Microwave | ◆ OpenImages (Microwave oven) |
| 202 | ★ Refrigerator | ◆ OpenImages |
| 203 | ★ Stove / Oven | ◆ OpenImages |
| 204 | ★ Washing machine | ◆ OpenImages |
| 205 | ★ Dryer | — |
| 206 | ★ Dishwasher | ◆ OpenImages |
| 207 | ★ Trash can | ◆ OpenImages (Waste container) |
| 208 | ★ Recycling bin | — |
| 209 | ★ Tissue box | ◆ OpenImages (Facial tissue holder) |
| 210 | ★ Toilet paper | ◆ OpenImages |
| 211 | ★ Soap dispenser | ◆ OpenImages |
| 212 | ★ Towel | ◆ OpenImages |
| 213 | ★ Blanket | — |
| 214 | ★ Pillow | ◆ OpenImages, ● ML Kit |
| 215 | ★ Bathrobe | — |
| 216 | ★ Toothbrush | ◆ OpenImages |
| 217 | ★ Toothpaste | — |
| 218 | ★ Hairbrush | — |
| 219 | ★ Comb | — |
| 220 | ★ Razor | — |
| 221 | ★ Scissors | ◆ OpenImages |
| 222 | ★ Pen | ◆ OpenImages |
| 223 | ★ Pencil | — |
| 224 | ★ Notebook | — |
| 225 | ★ Envelope | ◆ OpenImages |
| 226 | ★ Mail / Letters | — |
| 227 | ★ Keys | — |
| 228 | ★ Wallet | — |
| 229 | ★ Purse / Handbag | ◆ OpenImages |
| 230 | ★ Backpack | ◆ OpenImages |
| 231 | ★ Umbrella | ◆ OpenImages |
| 232 | ★ Sunglasses | ◆ OpenImages, ● ML Kit |
| 233 | ★ Glasses (reading) | ◆ OpenImages, ● ML Kit |
| 234 | ★ Watch (wrist) | ◆ OpenImages |
| 235 | ★ Candle | ◆ OpenImages |
| 236 | ★ Photo frame | ◆ OpenImages (Picture frame) |
| 237 | ★ Mirror | ◆ OpenImages |
| 238 | ★ Shelf | ◆ OpenImages |
| 239 | ★ Drawer | ◆ OpenImages |
| 240 | ★ Closet | ◆ OpenImages |
| 241 | ★ Hanger | — |
| 242 | ★ Laundry basket | — |
| 243 | ★ Iron (clothes) | — |
| 244 | ★ Ironing board | — |
| 245 | ★ Broom | — |
| 246 | ★ Mop | — |
| 247 | ★ Vacuum cleaner | — |
| 248 | ★ Sponge | — |
| 249 | ★ Bucket | — |
| 250 | ★ Garden hose | — |
| 251 | ★ Flashlight | ◆ OpenImages |
| 252 | ★ Battery | — |
| 253 | ★ Extension cord | — |
| 254 | ★ Power strip | — |
| 255 | ★ Plug / Outlet | ◆ OpenImages (Power plugs and sockets) |
| 256 | ★ Smoke detector | — |
| 257 | ★ Fire extinguisher | — |
| 258 | ★ First aid kit | — |
| 259 | ★ Tape (clear/masking) | — |
| 260 | ★ Glue | — |
| 261 | ★ Toolbox | — |
| 262 | ★ Hammer | ◆ OpenImages |
| 263 | ★ Screwdriver | ◆ OpenImages |
| 264 | ★ Tape measure | — |
| 265 | ★ Magnifying glass | — |

### 7. Food & Groceries (fine-grained for AAC) (80 classes)

ML Kit detects "Food" and "Fruit" generically. AAC users need specific items for requesting meals:

| # | Class | Notes |
|---|-------|-------|
| 266 | ★ Apple | ◆ OpenImages |
| 267 | ★ Banana | ◆ OpenImages |
| 268 | ★ Orange | ◆ OpenImages |
| 269 | ★ Grape | ◆ OpenImages |
| 270 | ★ Strawberry | ◆ OpenImages |
| 271 | ★ Watermelon | ◆ OpenImages |
| 272 | ★ Lemon | ◆ OpenImages |
| 273 | ★ Pear | ◆ OpenImages |
| 274 | ★ Peach | ◆ OpenImages |
| 275 | ★ Pineapple | ◆ OpenImages |
| 276 | ★ Mango | ◆ OpenImages |
| 277 | ★ Tomato | ◆ OpenImages |
| 278 | ★ Cucumber | ◆ OpenImages |
| 279 | ★ Carrot | ◆ OpenImages |
| 280 | ★ Broccoli | ◆ OpenImages |
| 281 | ★ Potato | ◆ OpenImages |
| 282 | ★ Lettuce / Salad | ◆ OpenImages (Salad) |
| 283 | ★ Corn | — |
| 284 | ★ Rice | — |
| 285 | ★ Pasta / Noodles | ◆ OpenImages (Pasta) |
| 286 | ★ Bread (loaf) | ◆ OpenImages |
| 287 | ★ Toast | — |
| 288 | ★ Cereal (bowl/box) | — |
| 289 | ★ Oatmeal | — |
| 290 | ★ Soup | — |
| 291 | ★ Sandwich | ◆ OpenImages |
| 292 | ★ Hamburger | ◆ OpenImages |
| 293 | ★ Hot dog | ◆ OpenImages, ● ML Kit |
| 294 | ★ Pizza | ◆ OpenImages, ● ML Kit |
| 295 | ★ Taco | ◆ OpenImages |
| 296 | ★ Chicken (cooked) | ◆ OpenImages |
| 297 | ★ Fish (cooked) | — |
| 298 | ★ Steak / Meat | — |
| 299 | ★ Egg (cooked) | ◆ OpenImages (Egg) |
| 300 | ★ Cheese | ◆ OpenImages |
| 301 | ★ Butter | — |
| 302 | ★ Yogurt | — |
| 303 | ★ Milk carton | ◆ OpenImages (partial — Dairy Product) |
| 304 | ★ Juice box | — |
| 305 | ★ Water bottle | ◆ OpenImages (Bottle) |
| 306 | ★ Soda can | ◆ OpenImages (Tin can) |
| 307 | ★ Coffee cup | ◆ OpenImages |
| 308 | ★ Tea cup | ◆ OpenImages (partial) |
| 309 | ★ Ice cream | ◆ OpenImages |
| 310 | ★ Cookie | ◆ OpenImages, ● ML Kit |
| 311 | ★ Cake | ◆ OpenImages, ● ML Kit |
| 312 | ★ Pudding | — |
| 313 | ★ Jello | — |
| 314 | ★ Candy | ◆ OpenImages |
| 315 | ★ Chocolate | — |
| 316 | ★ Chips / Crisps | — |
| 317 | ★ Crackers | — |
| 318 | ★ Popcorn | ◆ OpenImages |
| 319 | ★ Peanut butter jar | — |
| 320 | ★ Jam / Jelly jar | — |
| 321 | ★ Ketchup bottle | — |
| 322 | ★ Mustard bottle | — |
| 323 | ★ Salt shaker | ◆ OpenImages (Salt and pepper shakers) |
| 324 | ★ Pepper shaker | ◆ OpenImages |
| 325 | ★ Sugar bowl | — |
| 326 | ★ Honey bottle | — |
| 327 | ★ Can (canned food) | ◆ OpenImages (Tin can) |
| 328 | ★ Frozen meal box | — |
| 329 | ★ Microwave meal tray | — |
| 330 | ★ Baby food jar | — |
| 331 | ★ Protein bar | — |
| 332 | ★ Granola bar | — |
| 333 | ★ Fruit cup | — |
| 334 | ★ Applesauce cup | — |
| 335 | ★ Muffin | ◆ OpenImages |
| 336 | ★ Bagel | ◆ OpenImages |
| 337 | ★ Donut | ◆ OpenImages (Doughnut) |
| 338 | ★ Pancake | ◆ OpenImages |
| 339 | ★ Waffle | ◆ OpenImages |
| 340 | ★ French fries | ◆ OpenImages |
| 341 | ★ Sushi | ◆ OpenImages, ● ML Kit |
| 342 | ★ Pizza box | — |
| 343 | ★ Takeout container | — |
| 344 | ★ Paper plate | — |
| 345 | ★ Napkin | — |

### 8. Clothing & Personal Items (35 classes)

| # | Class | Notes |
|---|-------|-------|
| 346 | ★ T-shirt | ◆ OpenImages (Shirt) |
| 347 | ★ Pants / Trousers | ◆ OpenImages |
| 348 | ★ Shorts | ◆ OpenImages, ● ML Kit |
| 349 | ★ Dress | ◆ OpenImages, ● ML Kit |
| 350 | ★ Skirt | ◆ OpenImages |
| 351 | ★ Sweater | — |
| 352 | ★ Hoodie | — |
| 353 | ★ Coat / Jacket | ◆ OpenImages, ● ML Kit |
| 354 | ★ Socks | ◆ OpenImages |
| 355 | ★ Shoes (general) | ◆ OpenImages (Footwear), ● ML Kit |
| 356 | ★ Sneakers | ◆ OpenImages |
| 357 | ★ Sandals | ◆ OpenImages |
| 358 | ★ Slippers | — |
| 359 | ★ Boots | ◆ OpenImages |
| 360 | ★ Hat / Cap | ◆ OpenImages, ● ML Kit |
| 361 | ★ Scarf | ◆ OpenImages, ● ML Kit |
| 362 | ★ Gloves | ◆ OpenImages |
| 363 | ★ Belt | ◆ OpenImages |
| 364 | ★ Tie | ◆ OpenImages, ● ML Kit |
| 365 | ★ Pajamas | — |
| 366 | ★ Bathrobe | — |
| 367 | ★ Underwear | — |
| 368 | ★ Bra | ◆ OpenImages (Brassiere) |
| 369 | ★ Swimsuit | ● ML Kit (Swimwear) |
| 370 | ★ Rain jacket | — |
| 371 | ★ Velcro shoes (adaptive) | — |
| 372 | ★ Elastic waist pants (adaptive) | — |
| 373 | ★ Magnetic button shirt (adaptive) | — |
| 374 | ★ Adaptive clothing (general) | — |
| 375 | ★ Jewelry (ring, necklace) | ◆ OpenImages |
| 376 | ★ Earrings | ◆ OpenImages |
| 377 | ★ Bracelet | ● ML Kit |
| 378 | ★ Hair tie / Scrunchie | — |
| 379 | ★ Headband | — |
| 380 | ★ Diaper | ◆ OpenImages |

### 9. People, Pets & Social (30 classes)

| # | Class | Notes |
|---|-------|-------|
| 381 | ★ Person (adult) | ◆ OpenImages, ● ML Kit |
| 382 | ★ Child / Kid | ◆ OpenImages (Boy, Girl) |
| 383 | ★ Baby / Infant | ◆ OpenImages (partial) |
| 384 | ★ Elderly person | — |
| 385 | ★ Caregiver / Nurse | — |
| 386 | ★ Doctor (white coat) | — |
| 387 | ★ Therapist | — |
| 388 | ★ Family group | — |
| 389 | ★ Dog | ◆ OpenImages, ● ML Kit |
| 390 | ★ Cat | ◆ OpenImages, ● ML Kit |
| 391 | ★ Bird (pet) | ◆ OpenImages, ● ML Kit |
| 392 | ★ Fish (aquarium) | ◆ OpenImages |
| 393 | ★ Rabbit | ◆ OpenImages |
| 394 | ★ Hamster | ◆ OpenImages |
| 395 | ★ Guinea pig | — |
| 396 | ★ Turtle (pet) | ◆ OpenImages |
| 397 | ★ Dog leash | — |
| 398 | ★ Dog bowl | — |
| 399 | ★ Cat litter box | — |
| 400 | ★ Pet food bag | — |
| 401 | ★ Pet toy | — |
| 402 | ★ Pet bed | ◆ OpenImages (Dog bed) |
| 403 | ★ Pet carrier | — |
| 404 | ★ Fish tank | — |
| 405 | ★ Bird cage | — |
| 406 | ★ Visitor | — |
| 407 | ★ Hand wave (greeting gesture) | — |
| 408 | ★ Thumbs up (gesture) | — |
| 409 | ★ Pointing (gesture) | — |
| 410 | ★ Hug | — |

### 10. Activities & Rooms (40 classes)

| # | Class | Notes |
|---|-------|-------|
| 411 | ★ Kitchen | — |
| 412 | ★ Bathroom | ● ML Kit |
| 413 | ★ Bedroom | ● ML Kit |
| 414 | ★ Living room | — |
| 415 | ★ Dining room | — |
| 416 | ★ Hallway | — |
| 417 | ★ Front door | ◆ OpenImages (Door) |
| 418 | ★ Porch / Patio | ◆ OpenImages (Porch) |
| 419 | ★ Garden / Yard | ◆ OpenImages (partial) |
| 420 | ★ Garage | — |
| 421 | ★ Car (parked) | ◆ OpenImages, ● ML Kit |
| 422 | ★ Driveway | — |
| 423 | ★ Mailbox | — |
| 424 | ★ TV (on) | ◆ OpenImages (Television), ● ML Kit |
| 425 | ★ Computer screen | ◆ OpenImages (Computer monitor) |
| 426 | ★ Tablet screen | ◆ OpenImages (Tablet computer) |
| 427 | ★ Phone screen | ◆ OpenImages (Mobile phone), ● ML Kit |
| 428 | ★ Book (open) | ◆ OpenImages, ● ML Kit |
| 429 | ★ Newspaper | ● ML Kit |
| 430 | ★ Magazine | — |
| 431 | ★ Puzzle | — |
| 432 | ★ Board game | — |
| 433 | ★ Playing cards | — |
| 434 | ★ Coloring book | — |
| 435 | ★ Craft supplies | — |
| 436 | ★ Yarn / Knitting | ● ML Kit (Knitting) |
| 437 | ★ Sewing machine | ◆ OpenImages |
| 438 | ★ Radio | — |
| 439 | ★ Headphones | ◆ OpenImages |
| 440 | ★ Speaker | — |
| 441 | ★ Musical instrument | ◆ OpenImages, ● ML Kit |
| 442 | ★ Paint brush | — |
| 443 | ★ Canvas / Easel | — |
| 444 | ★ Plant (indoor) | ◆ OpenImages (Houseplant), ● ML Kit |
| 445 | ★ Flower vase | ◆ OpenImages (Vase) |
| 446 | ★ Watering can | — |
| 447 | ★ Bird feeder | — |
| 448 | ★ Rocking chair | — |
| 449 | ★ Recliner | — |
| 450 | ★ Wheelchair at table | — |

### 11. Outdoors & Community (50 classes)

| # | Class | Notes |
|---|-------|-------|
| 451 | ★ Sidewalk | — |
| 452 | ★ Crosswalk | — |
| 453 | ★ Traffic light | ◆ OpenImages |
| 454 | ★ Stop sign | ◆ OpenImages |
| 455 | ★ Handicap parking sign | — |
| 456 | ★ Wheelchair ramp (outdoor) | — |
| 457 | ★ Elevator | — |
| 458 | ★ Escalator | — |
| 459 | ★ Bench (park) | ◆ OpenImages |
| 460 | ★ Bus stop | — |
| 461 | ★ Bus | ◆ OpenImages, ● ML Kit |
| 462 | ★ Taxi | ◆ OpenImages |
| 463 | ★ Ambulance | ◆ OpenImages |
| 464 | ★ Hospital building | — |
| 465 | ★ Pharmacy | — |
| 466 | ★ Doctor's office | — |
| 467 | ★ Grocery store | ◆ OpenImages (Convenience store) |
| 468 | ★ Church | ● ML Kit |
| 469 | ★ Library | — |
| 470 | ★ Post office | — |
| 471 | ★ Bank | — |
| 472 | ★ Restaurant | — |
| 473 | ★ Parking lot | — |
| 474 | ★ Gas station | — |
| 475 | ★ Park | ● ML Kit |
| 476 | ★ Playground | ● ML Kit |
| 477 | ★ Swimming pool | ◆ OpenImages |
| 478 | ★ Beach | ● ML Kit |
| 479 | ★ Lake | ● ML Kit |
| 480 | ★ River | ● ML Kit |
| 481 | ★ Tree | ◆ OpenImages, ● ML Kit |
| 482 | ★ Grass | — |
| 483 | ★ Sky | ● ML Kit |
| 484 | ★ Cloud | — |
| 485 | ★ Sun | — |
| 486 | ★ Moon | ● ML Kit |
| 487 | ★ Rain | — |
| 488 | ★ Snow | — |
| 489 | ★ Puddle | — |
| 490 | ★ Mud | — |
| 491 | ★ Sandbox | — |
| 492 | ★ Swing (playground) | — |
| 493 | ★ Slide (playground) | — |
| 494 | ★ Bicycle | ◆ OpenImages, ● ML Kit |
| 495 | ★ Scooter | — |
| 496 | ★ Stroller | — |
| 497 | ★ Shopping cart | ◆ OpenImages (Cart) |
| 498 | ★ Trash can (outdoor) | ◆ OpenImages (Waste container) |
| 499 | ★ Fire hydrant | ◆ OpenImages |
| 500 | ★ Fountain | ◆ OpenImages |

**Total: 500 classes across 11 domains.**

### Coverage summary

| Source | Classes in our catalog |
|--------|----------------------|
| Already in OpenImages V7 (600 box classes) | ~120 of 500 (24%) |
| Already in ML Kit default (~400 labels) | ~50 of 500 (10%) |
| **Need new training data** | **~330 of 500 (66%)** |

The biggest gaps are in domains 1–5 (mobility aids, medical equipment, AAC devices, therapy tools, adapted eating) — these are the classes that matter most for AAC and have essentially zero coverage in any general-purpose vision model.

---

## Phase 2: Dataset Sources

### Primary: OpenImages V7

- **URL:** https://storage.googleapis.com/openimages/web/index.html
- **Size:** 1.9M images, 16M bounding boxes, 600 object classes
- **License:** CC BY 4.0 (images), CC BY 4.0 (annotations)
- **Relevant classes:** ~120 of our 500 (household items, food, animals, vehicles, common objects)
- **Usability:** Excellent. Bounding boxes + image-level labels. Can be filtered by class. Well-documented download pipeline via FiftyOne or the official scripts.

### Secondary: Roboflow Universe (community datasets)

- **URL:** https://universe.roboflow.com
- **Relevant datasets found:**
  - Wheelchair detection: 514 images, bounding box annotations
  - Wheelchair + walker: 9,206 images
  - Mobility aids (wheelchair, crutches, walking frame, cane): multi-class
  - Medical pills: multiple datasets (MEDISEG: 8,262 images, 32 pill types)
- **License:** Varies per dataset (most CC BY 4.0 or CC0)
- **Usability:** Good. Pre-annotated in COCO/YOLO/VOC formats. Can export as TFRecord for TFLite training.

### Tertiary: Specialized datasets

| Dataset | Classes covered | Size | License |
|---------|----------------|------|---------|
| GroceryStoreDataset | 81 grocery classes (fruits, vegetables, packaged items) | 5,125 images | MIT |
| MYNursingHome | 25 elderly-home object classes (beds, cabinets, equipment) | 37,500 images | Research |
| NIH Pillbox | Medication pills reference images | 4,392 reference + 133,774 consumer images | Public domain |
| MEDISEG | 32 pill types with instance segmentation | 8,262 images | Research |
| NutriGreen | Food packaging labels (Nutri-Score, vegan, organic) | 10,472 images | CC BY 4.0 |

### Gap: classes requiring new data collection (~250 classes)

The biggest data gap is in **AAC-specific devices** and **adapted daily living equipment**:

- Communication boards, eye-gaze devices, switch access devices, PECS cards
- Adaptive utensils (weighted spoons, rocker knives, plate guards)
- Medical rehab equipment (therapy putty, parallel bars, peg boards)
- Specific adaptive clothing items (velcro shoes, magnetic button shirts)

**Recommended approach for gap classes:**

1. **Web scraping + manual curation:** Search medical supply retailers (e.g., Rehabmart, Patterson Medical, AbleData) for product images. Requires manual verification and annotation. Estimated 50–100 images per class minimum for transfer learning.
2. **Clinical partner data:** Partner with rehabilitation centers or AAC clinics to photograph real equipment in situ. Best quality for real-world accuracy. Requires IRB considerations for any patient-visible images.
3. **Synthetic data augmentation:** Use background randomization, rotation, scale, lighting variation to multiply small datasets 5–10x. TFLite Model Maker supports standard augmentation (flip, rotation, brightness, contrast).
4. **Incremental rollout:** Start with the ~250 classes that have existing data (OpenImages + Roboflow + specialty datasets). Add AAC-specific classes as data becomes available. The model architecture supports adding classes without full retraining via transfer learning.

---

## Phase 3: Training Pipeline & Size/Latency Budget

### Target Device

**Samsung Galaxy Tab S10+**
- SoC: MediaTek Dimensity 9300+
- NPU: APU 790 (supports TFLite/LiteRT natively, up to 33B parameter LLMs)
- RAM: 12 GB
- The NPU provides up to 12x acceleration over CPU for neural network inference

### Model Architecture Options

| Model | Params | FP32 Size | INT8 Size | Top-1 Accuracy (ImageNet) | Pixel 4 CPU Latency | Pixel 4 INT8 CPU | Notes |
|-------|--------|-----------|-----------|---------------------------|---------------------|------------------|-------|
| EfficientNet-Lite0 | 4.7M | ~19 MB | ~5 MB | 75.1% (74.4% INT8) | 12 ms | 6.5 ms | **Recommended.** Best latency/accuracy for AAC. |
| EfficientNet-Lite1 | 5.4M | ~22 MB | ~6 MB | 76.7% (75.9% INT8) | 18 ms | 9.1 ms | Marginal gain for 40% more latency. |
| EfficientNet-Lite2 | 6.1M | ~24 MB | ~7 MB | 77.6% (77.0% INT8) | 26 ms | 12 ms | Good if accuracy matters more than speed. |
| MobileNetV2 | 3.4M | ~14 MB | ~3.5 MB | 71.8% | 8 ms | — | Faster but significantly less accurate. |

**Recommendation: EfficientNet-Lite0 with INT8 quantization.**

- **Model size:** ~5 MB (INT8 quantized) — trivial to bundle in APK
- **Inference latency on Pixel 4 CPU:** 6.5 ms per frame
- **Estimated latency on Dimensity 9300+ NPU:** ~1–2 ms per frame (NPU provides 12x acceleration over CPU; even conservatively, the APU 790 should handle this in under 3 ms)
- **At 5 fps capture rate:** The model has 200 ms per frame. Even on CPU, 6.5 ms leaves 193.5 ms of headroom. The model is not the bottleneck — camera capture and image I/O are.

### Training Pipeline

```
┌─────────────────────────────────────────────┐
│  1. DATA COLLECTION                          │
│     OpenImages V7 (120 classes)              │
│     + Roboflow datasets (mobility aids)      │
│     + Specialty datasets (pills, groceries)  │
│     + Web-scraped AAC equipment images       │
│     Target: 50-100 images/class minimum      │
└──────────────────┬──────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────┐
│  2. DATA PREPROCESSING                       │
│     - Resize to 224x224 (EfficientNet-Lite0) │
│     - Augmentation: flip, rotate, brightness │
│     - Train/val/test split: 80/10/10         │
│     - Class balancing via oversampling        │
└──────────────────┬──────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────┐
│  3. TRANSFER LEARNING                        │
│     Base: EfficientNet-Lite0 (ImageNet)      │
│     Freeze: feature extractor layers         │
│     Train: new classification head (500 cls) │
│     Tool: TFLite Model Maker                 │
│     Epochs: 10-20 (with early stopping)      │
│     Optimizer: Adam, lr=0.001                │
└──────────────────┬──────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────┐
│  4. QUANTIZATION                             │
│     Post-training INT8 quantization          │
│     Representative dataset: 200 images       │
│     Accuracy loss: ~0.7% (per EfficientNet   │
│       benchmarks: 75.1% → 74.4%)            │
└──────────────────┬──────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────┐
│  5. INTEGRATION                              │
│     Bundle .tflite in Flutter assets/        │
│     Use google_mlkit_image_labeling with     │
│       CustomImageLabelerOptions              │
│     Replace default labeler in VisionService │
│     Update context_mappings.json for new     │
│       class names                            │
└──────────────────┬──────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────┐
│  6. VALIDATION                               │
│     A/B test: default model vs custom model  │
│     Metric: AAC-suggestion relevance         │
│       (% of frames where top suggestion      │
│        matches user's actual environment)     │
│     Test environments: kitchen, bedroom,     │
│       bathroom, therapy room, outdoors       │
└─────────────────────────────────────────────┘
```

### Flutter Integration (code change)

The change to `vision_service.dart` would be minimal:

```dart
// Current (default 447-class model):
final labelerOptions = ImageLabelerOptions(confidenceThreshold: 0.5);
_imageLabeler = ImageLabeler(options: labelerOptions);

// Custom model (drop-in replacement):
final localModel = LocalModel.fromAssetFilePath('assets/ml/aac_model.tflite');
final labelerOptions = CustomImageLabelerOptions(
  localModel: localModel,
  confidenceThreshold: 0.5,
  maxCount: 10,
);
_imageLabeler = ImageLabeler(options: labelerOptions);
```

ML Kit automatically extracts labels from the TFLite model's metadata. No other code changes needed — the rest of the pipeline (stability filter, context mapping, suggestion bar) works identically.

### Size Budget

| Component | Size |
|-----------|------|
| Current APK (debug) | ~85 MB |
| Custom TFLite model (INT8) | ~5 MB |
| **Impact** | +6% APK size |

This is negligible. The camera plugin and ML Kit SDK are already much larger than the model file.

---

## Phase 4: Per-User Personalization (Stretch Goal)

### Concept

Every stroke survivor's environment is unique. The generic model knows "cup" but not *their* favorite blue mug. It knows "chair" but not *their* recliner. Per-user personalization would let the model learn the specific objects in the user's daily life.

### Architecture

```
┌─────────────────────────────────────────────┐
│  PRE-TRAINED BASE MODEL (frozen)             │
│  EfficientNet-Lite0 feature extractor        │
│  Input: 224x224 image → 1280-dim embedding   │
└──────────────────┬──────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────┐
│  PERSONALIZATION HEAD (trainable on-device)  │
│  Small FC layer: 1280 → 128 → N_personal    │
│  N_personal = user's custom objects (5-50)   │
│  Trained on ~5-20 photos per personal object │
└──────────────────┬──────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────┐
│  COMBINED OUTPUT                             │
│  Base model classes (500) + personal (5-50)  │
│  Merged confidence scores → context mapping  │
└─────────────────────────────────────────────┘
```

### How It Would Work (User Experience)

1. **Caregiver enters "Learn Mode"** in Settings
2. Points camera at an object (e.g., Dave's favorite mug)
3. Takes 5–10 photos from different angles
4. Labels it: "Dave's mug" → maps to AAC symbol "drink"
5. The personalization head fine-tunes on-device (takes ~30 seconds on NPU)
6. From now on, seeing that specific mug triggers "drink" suggestions with higher confidence

### Technical Approach: Transfer Learning on-Device

TensorFlow Lite supports on-device personalization via a **"base + head" architecture**:

- **Base model:** The pretrained EfficientNet-Lite0 acts as a frozen feature extractor. It converts images to 1280-dimensional embeddings. This never changes on-device.
- **Head model:** A small fully-connected classifier (1280 → 128 → N) that maps embeddings to personal classes. This is randomly initialized and trained locally.
- **Training:** Standard SGD/Adam on the small head model. With 10 images per class and 5 personal classes, training takes ~30 seconds on a modern NPU.
- **Storage:** The personalized head is ~100 KB. Stored in app-internal storage, never leaves the device.

### Privacy

- All training data stays on-device. No images are uploaded.
- The frozen base model is the same for all users (bundled in APK).
- Only the small head model is personalized. It contains weights, not images.
- If the user resets the app, personal model is deleted.
- No federated learning needed for this use case — each user's model is fully independent.

### Feasibility Assessment

| Factor | Assessment |
|--------|-----------|
| Compute | Dimensity 9300+ NPU can train a 100K-parameter head in seconds. |
| Storage | ~100 KB per personalized head. Negligible. |
| UX complexity | Moderate. Caregiver must enter learn mode, take photos, assign labels. Could be simplified with guided UI. |
| Accuracy risk | With only 5-10 photos per class, the head may overfit. Mitigated by using the base model's robust embeddings — the head is just learning to distinguish a few objects in embedding space, which is much easier than raw pixel classification. |
| Implementation effort | Medium. TFLite's on-device training API exists but is less mature than inference. Flutter bindings may need platform channels. |

### Recommendation

Per-user personalization is **feasible and valuable** but should be Phase 2 of the custom model work. Phase 1 (the 500-class base model) delivers the largest improvement and should ship first. Personalization adds incremental value for power users.

---

## Comparison: Default ML Kit vs. Custom AAC Model

| Dimension | ML Kit Default | Custom AAC Model |
|-----------|---------------|-----------------|
| **Classes** | ~400 (consumer photography) | 500 (AAC-optimized) |
| **AAC-relevant classes** | ~50 (10%) | ~500 (100%) |
| **Mobility aids** | 0 | 45 |
| **Medical equipment** | 0 | 50 |
| **AAC/communication devices** | 0 | 25 |
| **Therapy tools** | 0 | 30 |
| **Adapted eating equipment** | 0 | 35 |
| **Fine-grained food** | ~10 (generic: "Food", "Fruit") | 80 (specific: "Apple", "Banana", "Soup") |
| **Model size** | ~4 MB (bundled in ML Kit SDK) | ~5 MB (bundled in APK assets) |
| **Inference latency** | ~6 ms (CPU) | ~6.5 ms (CPU), ~1–2 ms (NPU) |
| **Accuracy (ImageNet)** | ~75% | ~74–75% (transfer learning from same base) |
| **AAC suggestion relevance** | Low — most detections map to nothing | High — every class maps to AAC suggestions |
| **Maintenance** | Google maintains | We maintain |
| **Offline** | Yes | Yes |
| **APK size impact** | 0 (already included) | +5 MB |

### Key Insight

The custom model isn't about being *more accurate* at general image classification. ML Kit's default model is already good at that. The value is in **recognizing the right things** — the objects that actually trigger useful AAC suggestions for stroke survivors.

Currently, when the camera sees a pill organizer, ML Kit might label it "container" or "plastic" — neither of which maps to a useful AAC suggestion. A custom model would label it "pill organizer" and trigger suggestions like "medicine", "help", "time" (for medication time).

---

## Recommendation & Next Steps

### Verdict: Worth building, but phased.

The custom model addresses a real gap. The current ~400-class ML Kit model wastes most of its classification capacity on objects irrelevant to AAC users while missing the objects that matter most. A custom 500-class model focused on AAC-relevant objects would dramatically improve suggestion relevance.

### Phased Plan

**Phase A: Data Collection (no device needed)**
1. Download OpenImages V7 subset for ~120 matching classes
2. Download Roboflow mobility aid datasets
3. Download specialty datasets (pills, groceries, nursing home objects)
4. Web-scrape AAC equipment images from medical supply sites
5. Manual curation + annotation for gap classes
6. Target: 50–100 images per class, 500 classes = 25,000–50,000 images total

**Phase B: Model Training (GPU needed, not device)**
1. Set up TFLite Model Maker pipeline (Google Colab is sufficient)
2. Train EfficientNet-Lite0 with transfer learning on curated dataset
3. INT8 post-training quantization
4. Validate on held-out test set
5. Output: `aac_model.tflite` (~5 MB)

**Phase C: Integration (device needed for real testing)**
1. Replace `ImageLabelerOptions` with `CustomImageLabelerOptions` in `vision_service.dart`
2. Update `context_mappings.json` with new class-to-suggestion mappings for all 500 classes
3. Bundle model in `assets/ml/`
4. Test on Samsung Galaxy Tab S10+

**Phase D: Personalization (future)**
1. Implement base+head architecture
2. Build "Learn Mode" UI for caregivers
3. On-device fine-tuning via TFLite training API
4. Store personal models in app-internal storage

### Blocking Constraints

| Constraint | Phase affected | Workaround |
|-----------|---------------|-----------|
| No GPU for training | Phase B | Google Colab (free tier) or Kaggle notebooks |
| No physical device | Phase C | Android emulator for basic testing, but real camera + NPU perf needs hardware |
| No clinical partner for AAC equipment photos | Phase A (gap classes) | Start with web-scraped images; add clinical photos later |
| TFLite on-device training maturity | Phase D | Platform channels to native Android TFLite training API if Flutter bindings are missing |

### Cost

| Item | Cost |
|------|------|
| OpenImages V7 download | Free |
| Roboflow datasets | Free (community) |
| Google Colab GPU time | Free (T4) or $10/month (Pro for A100) |
| Model storage in APK | +5 MB (free) |
| **Total** | **$0–$10** |
