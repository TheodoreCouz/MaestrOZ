% mii song

local 
    Partition
    Silence
    TuTuTud5
    TuTuTuc5
in
    TuTuTud5 = drone(amount:3 note:d5)
    TuTuTuc5 = drone(amount:3 note:c5)
    Silence = silence(duration:1.0)
    Partition = [partition(
        [stretch(factor:0.35 [f#5 Silence a5 c6 Silence a5 Silence f#5 TuTuTud5 Silence c#5 Silence d5 f#5 a5 Silence c#6 Silence a5 Silence stretch(factor:0.35 [f#5 e6 e6 d6]) Silence Silence Silence g#5 Silence c#6 f#5 c#6 Silence g#5 Silence c#6 Silence g5 f#4 Silence e5 TuTuTuc5 Silence Silence TuTuTuc5 ])]
        )]
end