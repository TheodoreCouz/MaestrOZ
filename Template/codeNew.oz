
declare

%%%%%%%%%%%%%%%%%%%%%%%%UTILS%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fun {Concat A B}
    case A of H|T then
        H|{Concat T B}
    else
        B
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

%%%%%%%%%%%%%%%%%%%%%%%%MAIN-FUNCTIONS%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fun {PartitionToTimedList P}
    case P of H1|T1 then
        if {Label H1} == duration then 'duration_t'
        elseif {Label H1} == stretch then 'stretch_t'
        elseif {Label H1} == drone then
            {Concat {Drone H1.note H1.amount}{PartitionToTimedList T1}}
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