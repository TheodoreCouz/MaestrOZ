% mii song

local 
    Partition
    TuTuTud5
    TuTuTuc5
in
    TuTuTud5 = drone(amount:3 note:d5)
    TuTuTuc5 = drone(amount:3 note:c5)
    Partition = [partition(
        [stretch(factor:0.35 [f#5 silence a5 c6 silence a5 silence f#5 TuTuTud5 silence c#5 silence d5 f#5 a5 silence c#6 silence a5 silence silence silence silence g#5 silence c#6 f#5 c#6 silence g#5 silence c#6 silence g5 f#4 silence e5 TuTuTuc5 silence silence TuTuTuc5 ])]
        )]
end