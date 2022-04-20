
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

% return a note identical to [Note] but with the next semitone
fun {NextSemiTone Note} Name Octave Sharp in
    if Note.sharp then
        Sharp = false
        Octave = Note.octave

        if Note.name == c then
            Name = d
        elseif Note.name == d then
            Name = e
        elseif Note.name == f then
            Name = g
        elseif Note.name == g then
            Name = a
        elseif Note.name == a then
            Name = b
        else skip
        end
    else
        if Note.name == e then 
            Name = f
            Sharp = false
            Octave = Note.octave
        elseif Note.name == b then 
            Name = c
            Octave = Note.octave + 1
            Sharp = false
        else 
            Name = Note.name
            Sharp = true
            Octave = Note.octave
        end
    end
    note(
        duration:(Note.duration) 
        instrument:(Note.instrument) 
        name:Name 
        octave:Octave 
        sharp:Sharp
        )
end
        

% return a note identical to [Note] but with the previous semitone
fun {PreviousSemiTone Note} Name Octave Sharp in
    if Note.sharp then
        Sharp = false
        Octave = Note.octave
        Name = Note.name
    else
        if Note.name == c then
            Name = b
            Sharp = false
            Octave = Note.octave - 1
        elseif Note.name == d then
            Name = c
            Sharp = true
            Octave = Note.octave
        elseif Note.name == e then %
            Name = d
            Sharp = true
            Octave = Note.octave
        elseif Note.name == f then
            Name = e
            Sharp = false
            Octave = Note.octave
        elseif Note.name == g then
            Name = f
            Sharp = true
            Octave = Note.octave
        elseif Note.name == a then
            Name = g
            Sharp = true
            Octave = Note.octave
        elseif Note.name == b then 
            Name = a
            Octave = Note.octave 
            Sharp = true
        else skip
        end
    end
    note(
        duration:(Note.duration) 
        instrument:(Note.instrument) 
        name:Name 
        octave:Octave 
        sharp:Sharp
        )
end

% transpose [Note] of 1 semitone higher (lower)
fun {TransposeNote N Note}
    if N > 0 then 
        {NextSemiTone Note}
    else
        {PreviousSemiTone Note}
    end
end

% transpose every note of [Chord] of 1 semitone higher (lower)
fun {TransposeChord N Chord}
    case Chord of H|T then
        {TransposeNote N H}|{TransposeChord N T}
    else nil
    end
end

% transposes every item of [Partition] of 1 semitone higher (lower)
fun {TransposeOnce N Partition} Dir in
    case Partition of H|T then
        if {Label H} == note then
            {TransposeNote N H}|{TransposeOnce N T}
        else
            {TransposeChord N H}|{TransposeOnce N T}
        end
    else nil
    end
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