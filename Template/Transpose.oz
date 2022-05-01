% applies GetPoints to each element of [MusicEx]
fun {PartMixAux MusicEx}
    case MusicEx of H|T then
        case H of note(name:N octave:O sharp:S duration:D instrument:I) then
            {Append {Aux H} {PartMixAux T}}

        [] silence(duration:D) then 
            {Append {GetPoints D 0.0 0.0} {PartMixAux T}}
        
        [] nil then {PartMixAux T}

        [] H1|T1 then % is a chord
            case H1 of note(name:N octave:O sharp:S duration:D instrument:I) then
                {Append {MixChord H} {PartMixAux T}}
            else nil
            end

        else nil
        end
    else nil
    end
end

