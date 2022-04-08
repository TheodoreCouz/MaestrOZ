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

declare

fun {ProduceInts N} 
    fun {ProduceAux I N}
        {Delay 1000} 
        if I >= N then N|nil 
        else 
	        I|{ProduceAux I+1 N} 
        end 
    end 
in 
    {ProduceAux 1 N} 
end

S1 = {ProduceInts 10}
{Browse S1}


declare 
fun {Concat A B}
    case A of H|T then H|{Concat T B}
    [] nil then B
    end
end

A = [1 2 3]
B = [4 5 6]

{Browse {Concat A B}}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

declare

fun {IsExtendedNote Item} %return true si Item est une Extended note
    if {IsRecord Item} then ({Label Item} == note)
    else false
    end
 end 

fun {GetDuration Partition} % return la durée totale d'une partition
    local GetDurationAux in
       GetDurationAux = fun {$ Partition Acc}
          case Partition of nil then Acc
          [] H|T then
             if {IsExtendedNote H} then {GetDurationAux T Acc+H.duration} %si la head est une Extended note
             else then {GetDurationAux T Acc+H.2} %si la head est un extended chord
             end
          end
       end
       {GetDurationAux Partition 0}
    end
 end

 % should browse 2.0+2.0+2.0+2.0 = 8.0
 {Browse {GetDuration [note(duration = 2.0), note(duration = 2.0), note(duration = 2.0), [note(duration = 2.0), 2.0]}}

{Browse (false orelse false)}






