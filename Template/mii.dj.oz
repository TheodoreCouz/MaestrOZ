% mii song

local 
    Partition
    Silence
in
    Silence = silence(duration:1.0)
    Partition = [reverse(
[stretch(factor:0.25 [f#5 Silence a5 c6 Silence a5 Silence f#5 drone(amount:3 note:d5)])]
    )]
end