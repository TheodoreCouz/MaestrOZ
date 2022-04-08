%IsNote
%IsChord
%IsExtendedNote
%ChordToextended
%IsTransformation

declare 

%\insert '/home/theo/Code/Oz/MaestrOZ/Template/code.oz' 

NoteTrue = note(name:Name octave:4 sharp:true duration:1.0 instrument:none)
NoteFalse = nut(name:Name octave:4 sharp:true duration:1.0 instrument:none)

{Browse 'IsNote(NoteTrue) --> should print true'}
{Browse {IsNote NoteTrue}}

{Browse 'IsNote(NoteFalse) --> should print false'}
{Browse {IsNote NoteFalse}}

declare

fun {BuildList N}
    if N == 0 then nil
    else
        if N == 2 then N|thread {Repeater N {BuildList N-1}} end
        else N|{BuildList N-1}
        end
    end
end

proc {Repeater N T}
    if N == 0 then nil
    else 0|{Repeater N-1 T}
    end
end

{Browse {BuildList 4}}





