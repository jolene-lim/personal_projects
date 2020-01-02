breed [ parents parent ]
breed [ schools school ]
directed-link-breed [ admissions admission ]
directed-link-breed [ applications application ]

parents-own [ concern first-choice enrolled]
schools-own [ rank spaces ]
applications-own [ score ]

to setup
  ca
  create-parents num-parents [
    set color white
    set concern random-float 1
    set xcor random-xcor
    set ycor random-ycor
    set shape "person"]

  create-schools num-schools [
    set color blue
    set xcor random-xcor
    set ycor random-ycor
    set shape "house"
    set spaces capacity
    set rank who - num-parents + 1]

  reset-ticks
end

to go
  ask parents [
    if color = white [
      bid]
    ]

  ask schools [
    if spaces > 0 [
      let priority-applicants in-link-neighbors in-radius distance-buffer
      create-admissions-to up-to-n-of spaces priority-applicants
      set spaces spaces - count out-link-neighbors with [color = white]
      ask out-link-neighbors [set color green]
    ]
    if spaces > 0 [
      create-admissions-to up-to-n-of spaces in-link-neighbors with [color = white]
      set spaces spaces - count out-link-neighbors with [color = white]
      ask out-link-neighbors [set color green]
    ]
  ]
  ask parents [if color = green [set enrolled max [who] of in-link-neighbors]]
  ask links with [breed = applications] [die]
  tick
end

to bid
  ask parents [
    create-application-to min-one-of schools with [spaces > 0] [
      distance myself * [concern] of myself + rank * 1.5]
    ]
  if ticks = 0 [
    ask parents [
      let preference max [who] of out-link-neighbors
      set first-choice preference]]

end
@#$#@#$#@
GRAPHICS-WINDOW
297
14
734
452
-1
-1
13.0
1
10
1
1
1
0
1
1
1
-16
16
-16
16
0
0
1
ticks
30.0

BUTTON
30
94
126
127
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
148
93
238
126
NIL
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

INPUTBOX
192
26
278
86
capacity
100.0
1
0
Number

INPUTBOX
95
26
176
86
num-schools
5.0
1
0
Number

INPUTBOX
12
26
85
86
num-parents
500.0
1
0
Number

SLIDER
13
166
278
199
distance-buffer
distance-buffer
0
20
20.0
1
1
NIL
HORIZONTAL

MONITOR
742
14
944
59
Mean Distance from School
mean [link-length] of links with [breed = admissions]
2
1
11

MONITOR
33
240
237
285
Number of Enrolled Parents
count parents with [color = green]
17
1
11

PLOT
744
66
944
216
Mean Distance from School
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot mean [link-length] of links"

MONITOR
745
235
945
280
Proportion of Parents with First Choice
count parents with [first-choice = enrolled] / num-parents
17
1
11

MONITOR
33
299
238
344
Total Number of Spaces Left
sum [spaces] of schools
17
1
11

PLOT
744
294
944
444
Proportion of Parents with First Choice
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot count parents with [first-choice = enrolled] / num-parents"

@#$#@#$#@
## WHAT IS IT?

This model simulates the process of school enrolment, focusing on the effect of policies that prioritise enrolment of children living near the school. It explores how varying distance buffers (within which children will be given priority) will affect the spatial pattern of enrolment and satisfaction among parents.

## HOW IT WORKS
The model occurs in a spatial environment. The world is set to 32 x 32 units and is wrapped.

The SETUP procedure creates a population of parents and schools. Parents have a concern factor, which represents how much they care about rankings (higher factor = less concerned) and is different for each parent. They also have a first-choice property (the school with the lowest distance-decay score for them) and enrolled property (the school they are ultimately enrolled in).

Schools are given a rank, starting from 1 ("the best school") based on their turtle ID. They also have a SPACES property which is equal to user-defined CAPACITY initially, but decreases along the enrolment process.

The GO procedure allows the enrolment process to begin. At the start of each tick, unenrolled parents will bid for their first-choice school using a distance decay formula, Distance (to school) * CONCERN + rank * 1.5. Parents will create an application link to schools with spaces available with the lowest score based on this formula. (Note: further explanation of formula available under Things to Note section).

Schools will then first create enrolment links with parents within the DISTANCE-BUFFER. If there are still spaces in the school, schools will randomly create links with students, up to capacity. Each tick ends after this is completed.

In subsequent ticks, parents will continue to bid for the school with the lowest distance-decay score, as long as it is available. Schools will then enroll them according to the rules above.

## HOW TO USE IT

NUM-PARENTS and NUM-SCHOOLS allows users to input the desired number of parents and schools in the world, respectively.
CAPACITY allows users to determine the number of spaces in each school. This will be the same for all schools.
DISTANCE-BUFFER allows users to determine the distance within which parents living near the school will be given priority. For example, if set to 20, all parents within a radius of 20 units from the school will be enrolled first.

## THINGS TO NOTICE
The two key outputs of the model are (1) spatial pattern of enrolment, measured by the mean distance between parents and their enrolled schools and (2) satisfaction among parents, measured by the proportion of parents who have enrolled in the school of their first choice.

How do different distance buffers affect the mean distance children live from their school and the proportion of satisfied parents?

## THINGS TO TRY

Users could try varying the setup such that there will be scenarios leading to under-enrollment or over-enrollment. 

## THINGS TO NOTE
The concern factor in the formula is applied to distance as it represents a "discount" on distance. Hence, a lower factor is seen to represent more concern for rankings; in an extreme case, a parent with a factor of 0 would only care about rankings. 

Also, as this world is 32 x 32, distances between schools and parents are often in the range of ~10. Hence, rankings are multiplied by 1.5 to make the units of rankings more comparable to distance units.


## EXTENDING THE MODEL

One drawback to the model is that it is currently computationally intensive, especially at the start, as parents will have to consider all schools (i.e. calculate the formula for each school) before deciding which to bid for. Extensions could consider the optimal radius of schools parents should consider (i.e., if a school is too far, parents will not go for it regardless of rank).

Moreover, currently satisfaction is measured through the proportion of parents who have enrolled in their first choice of schools. Extensions could consider how to report satisfaction based on the difference between the score (based on the distance decay formula) of one's first choice and enrolled school.

Instead of having a uniform capacity for each school, extensions could be made such that schools of different capacities exist.

Finally, one could extend and apply this basic model to a real-world GIS environment. This could allow policy-makers to understand the optimal distance buffers to achieve various targets. 

## CREDITS AND REFERENCES

An analysis of the model outputs can be found on atfirstsightofsun.wixsite.com/complexcity
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.1.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="distance" repetitions="20" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <exitCondition>count parents with [color = green] = num-parents</exitCondition>
    <metric>mean [link-length] of admissions</metric>
    <enumeratedValueSet variable="capacity">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-parents">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-buffer">
      <value value="0"/>
      <value value="5"/>
      <value value="10"/>
      <value value="15"/>
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-schools">
      <value value="5"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="satisfaction" repetitions="20" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <exitCondition>count parents with [color = green] = num-parents</exitCondition>
    <metric>count parents with [first-choice = enrolled] / num-parents</metric>
    <enumeratedValueSet variable="capacity">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-parents">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-buffer">
      <value value="0"/>
      <value value="5"/>
      <value value="10"/>
      <value value="15"/>
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-schools">
      <value value="5"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
