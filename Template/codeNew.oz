
declare

%%%%%%%%%%%%%%%%%%%%VARIABLES%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

PI = 3.14159265358979
U = 44100.0

%%%%%%%%%%%%%%%%%%%%%%%%UTILS%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Appends [B] to [A]
fun {Concat A B}
    case A of H|T then
        H|{Concat T B}
    else
        B
    end
end

% returns the total duration of [Partition]
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

% returns the rounded division between A and B (A//B in python)
fun {RoundedDiv A B}
    if B == 0 then 0
    else 
        {FloatToInt {IntToFloat A}/{IntToFloat B}}
    end
end

% returns the postition of a Note (Ex pos(c0) ==> 0)
fun {GetPos Note}
    if Note.name == c then
        if Note.sharp then 2
        else 1
        end
    elseif Note.name == d then
        if Note.sharp then 4
        else 3
        end
    elseif Note.name == e then 5
    elseif Note.name == f then
        if Note.sharp then 7
        else 6
        end
    elseif Note.name == g then
        if Note.sharp then 9
        else 8
        end
    elseif Note.name == a then
        if Note.sharp then 11
        else 10
        end
    elseif Note.name == b then 12
    else ~1
    end
end



% returns the next notes (n tones)
fun {NextNote N Note} Spectrum Start Index Oct FOct Res in
    Spectrum = s(c1 c#1 d1 d#1 e1 f1 f#1 g1 g#1 a1 a#1 b1)
    Start = {GetPos Note}

    if ((Start+N) mod 12) < 0 then
        Index = 12 + ((Start+N) mod 12)
    elseif ((Start+N) mod 12) > 0 then
        Index = ((Start+N) mod 12)
    else Index = 12
    end

    Res = {NoteToExtended Spectrum.Index}
    Oct = Note.octave + {RoundedDiv (Start+N) 12}

    if Oct > 10 orelse Oct < 0 then FOct = 0
    else FOct = Oct
    end

    note( % builds the final note to return
        duration:Note.duration
        instrument:Note.instrument
        name:Res.name
        octave:FOct 
        sharp:Res.sharp
    )
end

% returns the next notes (n tones)
fun {NextChord N Chord}
    case Chord of H|T then
        {NextNote N H}|{NextChord N T}
    else nil
    end
end

% returns the height of a note (considering A4 as 0)
fun {GetH Note} Pos in
    Pos = {GetPos Note} - 1
    {IntToFloat (Pos + (Note.octave*12) - 57)}
end

% returns the frequence of a note (Ex: GetFreq(a4) = 440)
fun {GetFreq Note} Power H Final in
    H = {GetH Note}
    Power = {Pow 2.0 H/12.0}
    Final = Power*440.0
    Final
end

% return a sample following formula n°2
fun {Sample F I}
    0.5*{Float.sin (2.0*PI*I/U)}
end

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

% adds [Amount] times the [Sound] to the partition
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

% stretches the duration of [Partition] by [Factor]
fun {Stretch Factor Partition} % Factor must be a float
    local 
        fun {StretchAux Factor Partition}
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
    in
        {StretchAux Factor {PartitionToTimedList Partition}}
    end
end

% sets the total duration of the [Partition] to [Seconds]
fun {Duration Seconds Partition} TD Coef in % [Seconds] must be a float
    local 
        fun {DurationAux Seconds Partition}
            TD = {TotalDuration Partition}
            Coef = Seconds/TD
            {Stretch Coef Partition}
        end
    in
        {DurationAux Seconds {PartitionToTimedList Partition}}
    end
end      

% Transposes [Partition] of [Semitones] semitones.
fun {Transpose Semitones Partition} 
    local 
        fun {TransposeAux Semitones Partition}
            case Partition of H|T then
                case H of note(name:N octave:O sharp:S duration:D instrument:I) then
                    {NextNote Semitones H}|{Transpose Semitones T}
                else 
                    {NextChord Semitones H}|{Transpose Semitones T}
                end
            else nil
            end
        end
    in
        {TransposeAux Semitones {PartitionToTimedList Partition}}
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%MAIN-FUNCTIONS%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fun {PartitionToTimedList P}
    case P of H|T then

        case H of duration(seconds:S partition:P) then
            {Concat {Duration H.seconds H.partition}{PartitionToTimedList T}}

        [] stretch(factor:F partition:P) then
            {Concat {Stretch H.factor H.partition}{PartitionToTimedList T}}

        [] drone(note:N amount:A) then
            {Concat {Drone H.note H.amount}{PartitionToTimedList T}} % works

        [] transpose(semitones:S partition:P) then
            {Concat {Transpose H.semitones H.partition}{PartitionToTimedList T}}

        else
            if {IsList H} then
                {ChordToExtended H}|{PartitionToTimedList T}
            else
                {NoteToExtended H}|{PartitionToTimedList T}
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

%Fonction qui échantillone la musique 
fun {PartMix P2T Music}
    local 
        MusicExtended 

        % returns a list of points associated to a note and its duration
        fun {GetPoints Note Freq I}
            if I == (Note.duration*U) then
                nil
            else
                {Sample Freq I}|{GetPoints Note Freq I+1.0}
            end
        end

        % applies GetPoints to each element of [MusicEx]
        fun {PartMixAux MusicEx}
            case MusicEx of H|T then
                {Concat {GetPoints H {GetFreq H} 1.0} {PartMixAux T}}
            else nil
            end
        end

    in
        MusicExtended = {P2T Music}
        {PartMixAux MusicExtended}
    end
end
        
