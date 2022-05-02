% mii song
local 
    Intro = [stretch(factor:0.25 [f#5 silence a5 c6 silence a5 silence f#5])]
    %Intro = [stretch(factor:0.35 [[f#5 f#4] silence [a4 a5] [c5 c6] silence [a4 a5] silence [f#4 f#5]])]
    Transition = [silence]
    Part1 = [stretch(factor:0.25 [c#5 d5 f#5 a5 c#6 silence a5 silence f#5])]
    LongMi = [stretch(factor:0.6 [e6])]
    Vocalise = [stretch(factor:0.28 [d#6 d6])]

    %[b4 d4] -> b mineur
    TuTuTud5 = [stretch(factor:0.25 [drone(note:d5  amount:3)])]
    TuTuTuc5 = [stretch(factor:0.25 [drone(note:c5 amount:3)])]
    Rest = [stretch(factor:0.25 [g#5 silence c#6 f#5 silence c#6 silence g#5 silence c#6 silence g5 f#4 silence e5])]
  

    PartitionFlattened = {Flatten [Intro TuTuTud5 Transition Part1 LongMi Vocalise Transition Rest TuTuTuc5 Transition TuTuTuc5]}
    %Partition =  [stretch(factor:0.35 [PartitionFlattened])]
in
    [partition(PartitionFlattened)]
end