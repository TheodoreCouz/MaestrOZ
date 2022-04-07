local
   % See project statement for API details.
   % !!! Please remove CWD identifier when submitting your project !!!
   CWD = '/home/theo/Code/Oz/MaestrOZ/Template' % Put here the **absolute** path to the project files
   [Project] = {Link [CWD#'Project2022.ozf']}
   Time = {Link ['x-oz://boot/Time']}.1.getReferenceTime

   \insert 'testPerso.oz'   

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   % Translate a note to the extended notation.
   fun {NoteToExtended Note}
      case Note
      of Name#Octave then
         note(name:Name octave:Octave sharp:true duration:1.0 instrument:none)
      [] Atom then
         case {AtomToString Atom}
         of [_] then
            note(name:Atom octave:4 sharp:false duration:1.0 instrument:none)
         [] [N O] then
            note(name:{StringToAtom [N]}
                 octave:{StringToInt [O]}
                 sharp:false
                 duration:1.0
                 instrument: none)
         end
      end
   end

   % Fonction qui convertit un chord en Extended Chord
   fun {ChordToExtended Chord}
      case Chord
      of Note|Tail then
         {NoteToExtended Note}|{ChordToExtended Tail}
      [] nil then nil
         % [] est l'équivalent d'un else if "case ... of"
         end
      end
   end

   fun {IsNote Item}
      {Browse yeye}
      case Item of Name#Octave then true
      [] Atom then 

         case {AtomToString Atom}
         of [_] then true

         [] [N O] then true

         else false
         end

      else false
      end
   end

   fun {IsChord Item}
      case Item of H|T then
         if {isNote H} then true
         else false
         end
      else false
      end
   end

   fun {IsExtendedNote Item}
      if {IsRecord Item} then
         if {Label Item} == note then true
         else false
         end
      else false
      end
   end 

   fun {IsTransformation Item}
      if {IsRecord Item}
         if {Label Item} == duration then true
         elseif {Label Item} == stretch then true
         elseif {Label Item} == drone then true
         elseif {Label Item} == transpose then true
         else false 
         end
      else false
      end
   end


   %TODO
   fun {Duration partition}
      % Cette transformation fixe la durée de la partition au nombre de secondes indiqué. Il faut donc
      %adapter la durée de chaque note et accord proportionnellement à leur durée actuelle pour que
      %la durée totale devienne celle indiquée dans la transformation.
      nil
   end

   fun {Stretch partition}
      %Cette transformation étire la durée de la partition par le facteur indiqué. Il faut donc étirer la
      %durée de chaque note et accord en conséquence.
      nil
   end

   fun {Drone }
   end

   fun {Transpose }
   end
   
   

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   fun {PartitionToTimedList Partition}
      case Partition of
      H|T then
         if {IsNote H} then {NoteToExtended H}|{PartitionToTimedList T}
         elseif {IsChord H} then {ChordToExtended H}|{PartitionToTimedList T}
         elseif {IsTransformation H} then 
            if {Label Item} == duration then {Duration H.seconds %partition}
            elseif {Label Item} == stretch then {Stretch H.factor %partition}
            elseif {Label Item} == drone then {Drone H.note H.amount}
            elseif {Label Item} == transpose then {Transpose H.semitones %partition}
            end
         else H|{PartitionToTimedList T}
         end
      [] nil then nil
      end
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   fun {Mix P2T Music}
      % TODO
      {Project.readFile CWD#'wave/animals/cow.wav'}
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   Music = {Project.load CWD#'joy.dj.oz'}
   Start

   % Uncomment next line to insert your tests.
   % \insert '/full/absolute/path/to/your/tests.oz'
   % !!! Remove this before submitting.
in
   Start = {Time}

   % Uncomment next line to run your tests.
   % {Test Mix PartitionToTimedList}

   % Add variables to this list to avoid "local variable used only once"
   % warnings.
   {ForAll [NoteToExtended Music] Wait}
   
   % Calls your code, prints the result and outputs the result to `out.wav`.
   % You don't need to modify this.
   {Browse {Project.run Mix PartitionToTimedList Music 'out.wav'}}
   
   % Shows the total time to run your code.
   {Browse {IntToFloat {Time}-Start} / 1000.0}
end

%%%%%%%%%%%%%%%%%%TESTS%%%%%%%%%%%%%%%%%%%%%%%

declare

NoteTrue = note(name:Name octave:4 sharp:true duration:1.0 instrument:none)
NoteFalse = nut(name:Name octave:4 sharp:true duration:1.0 instrument:none)

{Browse 'IsNote(NoteTrue) --> should print true'}
{Browse {IsNote NoteTrue}}

{Browse 'IsNote(NoteFalse) --> should print false'}
{Browse {IsNote NoteFalse}}
