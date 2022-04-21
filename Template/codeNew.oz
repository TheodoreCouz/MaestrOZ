
declare

%%%%%%%%%%%%%%%%%%%%%%%%UTILS%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Append [B] to [A]
fun {Concat A B}
    case A of H|T then
        H|{Concat T B}
    else
        B
    end
end

% return the total duration of [Partition]
fun {TotalDuration Partition}
    local
        fun {TotalDurationAux Partition Acc} 
            case Partition of H|T then
                if {Label H} == note then
                    {TotalDurationAux T Acc+H.duration}
                else
                    {TotalDurationAux T Acc+H.1.duration}
                end
            else Acc
            end
        end
    in
    {TotalDurationAux Partition 0.0}
    end
end

% return the next notes (n tones)
fun {NextNote N Note} Spectrum Start Index O Res in
    Spectrum = s(c1 c#1 d1 d#1 e1 f1 f#1 g1 g#1 a1 a#1 b1)
    if Note.name == c then
        if Note.sharp then Start = 2
        else Start = 1
        end
    elseif Note.name == d then
        if Note.sharp then Start = 4
        else Start = 3
        end
    elseif Note.name == e then
        Start = 5
    elseif Note.name == f then
        if Note.sharp then Start = 7
        else Start = 6
        end
    elseif Note.name == g then
        if Note.sharp then Start = 9
        else Start = 8
        end
    elseif Note.name == a then
        if Note.sharp then Start = 11
        else Start = 10
        end
    elseif Note.name == b then
        Start = 12
    else skip
    end
    if ((Start+N) mod 12) < 0 then
        Index = 12 + ((Start+N) mod 12)
    else Index = ((Start+N) mod 12)
    end
        
    Res = {NoteToExtended Spectrum.Index}
    O = Note.octave + {FloatToInt {IntToFloat (Start+N)}/{IntToFloat 12}}
    {Browse O}
    note(
        duartion:Note.duration
        instrument:Note.instrument
        name:Res.name
        octave:O 
        sharp:Res.sharp
    )
end

% return the next notes (n tones)



%%%%%%%%%%%%%%%%%%%%%%%%EXTENDED%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Translate a note to the extended notation.
fun {NoteToExtended Note}
    if {Label Note} == note then 
        Note
    else
        case Note of Name#Octave then
        note(name:Name octave:Octave sharp:true duration:1.0 instrument:none)
        [] Atom then
            case {AtomToString Atom}
            of [_] then
                note(name:Atom octave:4 sharp:false duration:1.0 instrument:none)
            [] [N O] then
                note(name:{StringToAtom [N]} octave:{StringToInt [O]} sharp:false duration:1.0 instrument: none)
            end
        end
    end
end

% Translate a chord to the extended notation.
fun {ChordToExtended Chord}
    case Chord of H|T then
        {NoteToExtended H}|{ChordToExtended T}
    else nil
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%TRANSITIONS%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% add [Amount] times the [Sound] to the partition
fun {Drone Sound Amount}
    if Amount == 0 then nil
    else
        local ExtendedSound in
             case Sound of H|T then 
                ExtendedSound = {ChordToExtended Sound}
             else ExtendedSound = {NoteToExtended Sound}
             end
        ExtendedSound|{Drone Sound Amount-1}
        end
    end
end

% stretch the duration of [Partition] by [Factor]
fun {Stretch Factor Partition}
    case Partition of H|T then
        case H of Head|Tail then
            (note(
                duration:(Head.duration*Factor) 
                instrument:(Head.instrument) 
                name:(Head.name) 
                octave:(Head.octave) 
                sharp:(Head.sharp)
                )|Tail)|{Stretch Factor T}
        else
            note(
                duration:(H.duration*Factor) 
                instrument:(H.instrument) 
                name:(H.name) 
                octave:(H.octave) 
                sharp:(H.sharp)
                )|{Stretch Factor T}
        end
    else nil
    end
end

% set the total duration of the [Partition] to [Seconds]
fun {Duration Seconds Partition} TD Coef in
    TD = {TotalDuration Partition}
    Coef = Seconds/TD
    {Stretch Coef Partition}
end      

% Transpose [Partition] of [Semitones] semitones.    

%%%%%%%%%%%%%%%%%%%%%%%%MAIN-FUNCTIONS%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fun {PartitionToTimedList P}
    case P of H1|T1 then
        if {Label H1} == duration then 'duration_t'
            % don't know how to include it
        elseif {Label H1} == stretch then 'stretch_t'
            % don't know how to include it
        elseif {Label H1} == drone then
            {Concat {Drone H1.note H1.amount}{PartitionToTimedList T1}} % works
        elseif {Label H1} == transpose then 'transpose_t'
        else
            case H1 of H2|T2 then
                {ChordToExtended H1}|{PartitionToTimedList T1}
            else
                {NoteToExtended H1}|{PartitionToTimedList T1}
            end
        end
    else nil
    end
end

fun {Mix P2T Music}
    % TODO
    %{Project.readFile CWD#'wave/animals/cow.wav'}
    1
end