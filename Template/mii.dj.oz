% mii song
local 
    Intro = [stretch(factor:0.25 [f#5 silence a5 c#6 silence a5 silence f#5])]
    %Intro = [stretch(factor:0.35 [[f#5 f#4] silence [a4 a5] [c5 c6] silence [a4 a5] silence [f#4 f#5]])]
    Transition = [silence]
    FastTransition = [stretch(factor:0.4 [silence])]
    Part1 = [stretch(factor:0.25 [c#5 d5 f#5 a5 c#6 silence a5 silence f#5])]
    LongMi = [stretch(factor:0.6 [e6])]
    LongRe = [stretch(factor:0.6 [d#5])]
    LongC = [stretch(factor:0.6 [c#6])]
    Vocalise = [stretch(factor:0.28 [d#6 d6])]

    %[b4 d4] -> b mineur
    TuTuTud5 = [stretch(factor:0.25 [drone(note:d5  amount:3)])]
    TuTuTuc5 = [stretch(factor:0.25 [drone(note:c5 amount:3)])]
    TuTuTue5 = [stretch(factor:0.25 [drone(note:e5 amount:3)])]
    TuTuTue6 = [stretch(factor:0.25 [drone(note:e6 amount:3)])]
    Part2 = [stretch(factor:0.25 [g#5 silence c#6 f#5 silence c#6 silence g#5 silence c#6 silence g5 f#5 silence e5])]
    Part3 = [stretch(factor:0.45 [d5 c#5])]
    Part4 = [stretch(factor:0.25 [silence a5 c#6 silence a5 silence f#5])]

    Part5 = [stretch(factor:0.25 [silence f#5 silence a5 c#6 silence a5 silence f#5])]
    Part6 = [stretch(factor:0.28 [b5 silence silence b5 g5 d5 c#5 b5 g5 c#5 a5 f#5 c5 b4 d5 d5 b4])]

  

    PartitionFlattened = {Flatten [Intro TuTuTud5 Transition Part1 LongMi Vocalise Transition Part2 FastTransition TuTuTuc5 FastTransition TuTuTuc5 FastTransition LongRe Part3 FastTransition Part4 FastTransition TuTuTue5 FastTransition TuTuTue6 FastTransition Part5 LongC Part6 Transition TuTuTue5]}
    %Partition =  [stretch(factor:0.35 [PartitionFlattened])]
in
    [partition(PartitionFlattened)]
end