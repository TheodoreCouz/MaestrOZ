PassedTests = {Cell.new 0}
TotalTests  = {Cell.new 0}

% Time in seconds corresponding to 5 samples.
FiveSamples = 0.00011337868

% Takes a list of samples, round them to 4 decimal places and multiply them by
% 10000. Use this to compare list of samples to avoid floating-point rounding
% errors.
fun {Normalize Samples}
   {Map Samples fun {$ S} {IntToFloat {FloatToInt S*10000.0}} end}
end

proc {Assert Cond Msg}
   TotalTests := @TotalTests + 1
   if {Not Cond} then
      {System.show Msg}
   else
      PassedTests := @PassedTests + 1
   end
end

proc {AssertEquals A E Msg}
   TotalTests := @TotalTests + 1
   if A \= E then
      {System.show Msg}
      {System.show actual(A)}
      {System.show expect(E)}
   else
      PassedTests := @PassedTests + 1
   end
end

proc {AssertNoteEquals A E Msg}
   TotalTests := @TotalTests + 1
   if {Label A} == note andthen {Label E} == note then
      if A.name == E.name andthen A.octave == E.octave andthen A.sharp == E.sharp andthen A.duration == E.duration andthen A.instrument == E.instrument then
         PassedTests := @PassedTests + 1
      else
         {System.show Msg}
         {System.show actual(name:A.name octave:A.octave sharp:A.sharp duration:A.duration instrument:A.instrument)}
         {System.show expect(name:E.name octave:E.octave sharp:E.sharp duration:E.duration instrument:E.instrument)}
      end
   elseif {Label A} == silence andthen {Label E} == silence then
      if A.duration == E.duration then
         PassedTests := @PassedTests + 1
      else
         {System.show Msg}
         {System.show actual(duration:A.duration)}
         {System.show expect(duration:E.duration)}
      end
   else
      {System.show Msg}
      {System.show actual(A)}
      {System.show expect(E)}
   end
end

proc {AssertNilEquals A E Msg}
   TotalTests := @TotalTests + 1
   if A == nil andthen E == nil then
      PassedTests := @PassedTests + 1
   else
      {System.show Msg}
      {System.show actual(A)}
      {System.show expect(E)}
   end
end

proc {AssertChordEqual ANE Liste1 Liste2}
   if Liste1 == nil then {AssertNilEquals Liste1 Liste2 there_s_a_problem_with_a_nil}
   elseif {IsList Liste1} then
      for X in 1..{List.length Liste1} do
         if {IsList {List.nth Liste1 X}} then
               {AssertChordEqual ANE {List.nth Liste1 X} {List.nth Liste2 X}}
         else
               {ANE {List.nth Liste1 X} {List.nth Liste2 X} there_s_a_problem_in_a_note}
         end
      end
   else
      {ANE Liste1 Liste2 there_s_a_problem_in_a_note}
   end
end

% Prevent warnings if these are not used.
{ForAll [FiveSamples Normalize Assert AssertEquals] Wait}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TEST PartitionToTimedNotes

proc {TestNotes P2T}
   % Test P1 Notes
   P1 = [a b2 c#3 d f#6]
   ExpectedFlatP1 = [note(name:a octave:4 sharp:false duration:1.0 instrument:none)
                    note(name:b octave:2 sharp:false duration:1.0 instrument:none)
                    note(name:c octave:3 sharp:true duration:1.0 instrument:none)
                    note(name:d octave:4 sharp:false duration:1.0 instrument:none)
                    note(name:f octave:6 sharp:true duration:1.0 instrument:none)]
   FlatP1

   % Test P2 Notes
   P2 = [a b a d f]
   ExpectedFlatP2 = [note(name:a octave:4 sharp:false duration:1.0 instrument:none)
                     note(name:b octave:4 sharp:false duration:1.0 instrument:none)
                     note(name:a octave:4 sharp:false duration:1.0 instrument:none)
                     note(name:d octave:4 sharp:false duration:1.0 instrument:none)
                     note(name:f octave:4 sharp:false duration:1.0 instrument:none)]
   FlatP2

   % Test P3 Notes
   P3 = [a4 b2 a3 d5 f5]
   ExpectedFlatP3 = [note(name:a octave:4 sharp:false duration:1.0 instrument:none)
                     note(name:b octave:2 sharp:false duration:1.0 instrument:none)
                     note(name:a octave:3 sharp:false duration:1.0 instrument:none)
                     note(name:d octave:5 sharp:false duration:1.0 instrument:none)
                     note(name:f octave:5 sharp:false duration:1.0 instrument:none)]
   FlatP3

   % Test P4 Notes
   P4 = [g#2 f#5 d#6]
   ExpectedFlatP4 = [note(name:g octave:2 sharp:true duration:1.0 instrument:none)
                     note(name:f octave:5 sharp:true duration:1.0 instrument:none)
                     note(name:d octave:6 sharp:true duration:1.0 instrument:none)]
   FlatP4

   % Test P5 Notes
   P5 = [silence silence]
   ExpectedFlatP5 = [silence(duration:1.0)
                     silence(duration:1.0)]
   FlatP5

   % Test P6 Notes
   P6 = [g5 a b#4 silence]
   ExpectedFlatP6 = [note(name:g octave:5 sharp:false duration:1.0 instrument:none)
                     note(name:a octave:4 sharp:false duration:1.0 instrument:none)
                     note(name:b octave:4 sharp:true duration:1.0 instrument:none)
                    silence(duration:1.0)]
   FlatP6
in
   % Test P1 Notes
   FlatP1 = {P2T P1}
   {AssertNoteEquals FlatP1.1 ExpectedFlatP1.1 first_note_of_P1_is_incorrect}
   {AssertNoteEquals FlatP1.2.1 ExpectedFlatP1.2.1 second_note_of_P1_is_incorrect}
   {AssertNoteEquals FlatP1.2.2.1 ExpectedFlatP1.2.2.1 third_note_of_P1_is_incorrect}
   {AssertNoteEquals FlatP1.2.2.2.1 ExpectedFlatP1.2.2.2.1 fourth_note_of_P1_is_incorrect}
   {AssertNoteEquals FlatP1.2.2.2.2.1 ExpectedFlatP1.2.2.2.2.1 fifth_note_of_P1_is_incorrect}

   % Test P2 Notes
   FlatP2 = {P2T P2}
   {AssertNoteEquals FlatP2.1 ExpectedFlatP2.1 first_note_of_P2_is_incorrect}
   {AssertNoteEquals FlatP2.2.1 ExpectedFlatP2.2.1 second_note_of_P2_is_incorrect}
   {AssertNoteEquals FlatP2.2.2.1 ExpectedFlatP2.2.2.1 third_note_of_P2_is_incorrect}
   {AssertNoteEquals FlatP2.2.2.2.1 ExpectedFlatP2.2.2.2.1 fourth_note_of_P2_is_incorrect}
   {AssertNoteEquals FlatP2.2.2.2.2.1 ExpectedFlatP2.2.2.2.2.1 fifth_note_of_P2_is_incorrect}

   % Test P3 Notes
   FlatP3 = {P2T P3}
   {AssertNoteEquals FlatP3.1 ExpectedFlatP3.1 first_note_of_P3_is_incorrect}
   {AssertNoteEquals FlatP3.2.1 ExpectedFlatP3.2.1 second_note_of_P3_is_incorrect}
   {AssertNoteEquals FlatP3.2.2.1 ExpectedFlatP3.2.2.1 third_note_of_P3_is_incorrect}
   {AssertNoteEquals FlatP3.2.2.2.1 ExpectedFlatP3.2.2.2.1 fourth_note_of_P3_is_incorrect}
   {AssertNoteEquals FlatP3.2.2.2.2.1 ExpectedFlatP3.2.2.2.2.1 fifth_note_of_P3_is_incorrect}

   % Test P4 Notes
   FlatP4 = {P2T P4}
   {AssertNoteEquals FlatP4.1 ExpectedFlatP4.1 first_note_of_P4_is_incorrect}
   {AssertNoteEquals FlatP4.2.1 ExpectedFlatP4.2.1 second_note_of_P4_is_incorrect}
   {AssertNoteEquals FlatP4.2.2.1 ExpectedFlatP4.2.2.1 third_note_of_P4_is_incorrect}

   % Test P5 Notes
   FlatP5 = {P2T P5}
   {AssertNoteEquals FlatP5.1 ExpectedFlatP5.1 first_note_of_P5_is_incorrect}
   {AssertNoteEquals FlatP5.2.1 ExpectedFlatP5.2.1 second_note_of_P5_is_incorrect}

   % Test P6 Notes
   FlatP6 = {P2T P6}
   {AssertNoteEquals FlatP6.1 ExpectedFlatP6.1 first_note_of_P6_is_incorrect}
   {AssertNoteEquals FlatP6.2.1 ExpectedFlatP6.2.1 second_note_of_P6_is_incorrect}
   {AssertNoteEquals FlatP6.2.2.1 ExpectedFlatP6.2.2.1 third_note_of_P6_is_incorrect}
   {AssertNoteEquals FlatP6.2.2.2.1 ExpectedFlatP6.2.2.2.1 fourth_note_of_P6_is_incorrect}
end

proc {TestChords P2T}
   % Test P1 Chords
   P1 = [[c#5 b] [a f1]]
   ExpectedFlatP1 = [[note(name:c octave:5 sharp:true duration:1.0 instrument:none)
                    note(name:b octave:4 sharp:false duration:1.0 instrument:none)]
                    [note(name:a octave:4 sharp:false duration:1.0 instrument:none)
                    note(name:f octave:1 sharp:false duration:1.0 instrument:none)]]
   FlatP1

   % Test P2 Chords
   P2 = [d#3 [g c#1] a2]
   ExpectedFlatP2 = [note(name:d octave:3 sharp:true duration:1.0 instrument:none)
                     [note(name:g octave:4 sharp:false duration:1.0 instrument:none)
                     note(name:c octave:1 sharp:true duration:1.0 instrument:none)]
                     note(name:a octave:2 sharp:false duration:1.0 instrument:none)]
   FlatP2

   % Test P3 Chords
   P3 = [[f d2 e#5 e1]]
   ExpectedFlatP3 = [[note(name:f octave:4 sharp:false duration:1.0 instrument:none)
                     note(name:d octave:2 sharp:false duration:1.0 instrument:none)
                     note(name:e octave:5 sharp:true duration:1.0 instrument:none)
                     note(name:e octave:1 sharp:false duration:1.0 instrument:none)]]
   FlatP3

   % Test P4 Chords
   P4 = [[c#5 silence b]]
   ExpectedFlatP4 = [[note(name:c octave:5 sharp:true duration:1.0 instrument:none)
                    silence(duration:1.0)
                    note(name:b octave:4 sharp:false duration:1.0 instrument:none)]]
   FlatP4

   % Test P5 Chords
   P5 = [[silence c#5 b]]
   ExpectedFlatP5 = [[silence(duration:1.0)
                  note(name:c octave:5 sharp:true duration:1.0 instrument:none)
                  note(name:b octave:4 sharp:false duration:1.0 instrument:none)]]
   FlatP5

   % Test P6 Chords
   P6 = [[silence c#5 silence]]
   ExpectedFlatP6 = [[silence(duration:1.0)
                  note(name:c octave:5 sharp:true duration:1.0 instrument:none)
                  silence(duration:1.0)]]
   FlatP6

   % Test P7 Chords
   P7 = [[silence(duration:1.0)
      note(name:c octave:5 sharp:true duration:1.0 instrument:none)
      silence(duration:1.0)]]
   ExpectedFlatP7 = [[silence(duration:1.0)
                  note(name:c octave:5 sharp:true duration:1.0 instrument:none)
                  silence(duration:1.0)]]
   FlatP7

   % Test P8 Chords
   P8 = [[note(name:c octave:5 sharp:true duration:1.0 instrument:none)
         silence(duration:1.0)
         note(name:b octave:4 sharp:false duration:1.0 instrument:none)]]
   ExpectedFlatP8 = [[note(name:c octave:5 sharp:true duration:1.0 instrument:none)
                    silence(duration:1.0)
                    note(name:b octave:4 sharp:false duration:1.0 instrument:none)]]
   FlatP8
in
   % Test P1 Chords
   FlatP1 = {P2T P1}
   {AssertChordEqual AssertNoteEquals FlatP1 ExpectedFlatP1}

   % Test P2 Chords
   FlatP2 = {P2T P2}
   {AssertChordEqual AssertNoteEquals FlatP2 ExpectedFlatP2}

   % Test P3 Chords
   FlatP3 = {P2T P3}
   {AssertChordEqual AssertNoteEquals FlatP3 ExpectedFlatP3}

   % Test P4 Chords
   FlatP4 = {P2T P4}
   for X in 1..{List.length FlatP4} do
      {AssertChordEqual AssertNoteEquals {List.nth FlatP4 X} {List.nth ExpectedFlatP4 X}}
   end

   % Test P5 Chords
   FlatP5 = {P2T P5}
   for X in 1..{List.length FlatP5} do
      {AssertChordEqual AssertNoteEquals {List.nth FlatP5 X} {List.nth ExpectedFlatP5 X}}
   end

   % Test P6 Chords
   FlatP6 = {P2T P6}
   for X in 1..{List.length FlatP6} do
      {AssertChordEqual AssertNoteEquals {List.nth FlatP6 X} {List.nth ExpectedFlatP6 X}}
   end

   % Test P7 Chords
   FlatP7 = {P2T P7}
   for X in 1..{List.length FlatP7} do
      {AssertChordEqual AssertNoteEquals {List.nth FlatP7 X} {List.nth ExpectedFlatP7 X}}
   end

   % Test P8 Chords
   FlatP8 = {P2T P8}
   for X in 1..{List.length FlatP8} do
      {AssertChordEqual AssertNoteEquals {List.nth FlatP8 X} {List.nth ExpectedFlatP8 X}}
   end
end

proc {TestIdentity P2T}
   % Test P1 Identity
   P1 = [note(name:a octave:4 sharp:false duration:1.0 instrument:none)
         note(name:b octave:2 sharp:false duration:1.0 instrument:none)
         note(name:c octave:3 sharp:true duration:1.0 instrument:none)
         note(name:d octave:4 sharp:false duration:1.0 instrument:none)
         note(name:f octave:6 sharp:true duration:1.0 instrument:none)]

   ExpectedFlatP1 = [note(name:a octave:4 sharp:false duration:1.0 instrument:none)
                     note(name:b octave:2 sharp:false duration:1.0 instrument:none)
                     note(name:c octave:3 sharp:true duration:1.0 instrument:none)
                     note(name:d octave:4 sharp:false duration:1.0 instrument:none)
                     note(name:f octave:6 sharp:true duration:1.0 instrument:none)]
   FlatP1

   % Test P2 Identity
   P2 = [[note(name:a octave:4 sharp:false duration:1.0 instrument:none)
         note(name:b octave:2 sharp:false duration:1.0 instrument:none)
         note(name:d octave:4 sharp:false duration:1.0 instrument:none)
         note(name:f octave:6 sharp:true duration:1.0 instrument:none)]]

   ExpectedFlatP2 = [[note(name:a octave:4 sharp:false duration:1.0 instrument:none)
                     note(name:b octave:2 sharp:false duration:1.0 instrument:none)
                     note(name:d octave:4 sharp:false duration:1.0 instrument:none)
                     note(name:f octave:6 sharp:true duration:1.0 instrument:none)]]
   FlatP2

   % Test P3 Identity
   P3 = [note(name:c octave:7 sharp:true duration:1.0 instrument:none)
         [note(name:a octave:4 sharp:false duration:1.0 instrument:none)
         note(name:b octave:2 sharp:false duration:1.0 instrument:none)
         note(name:d octave:4 sharp:false duration:1.0 instrument:none)]
         note(name:f octave:6 sharp:true duration:1.0 instrument:none)]

   ExpectedFlatP3 = [note(name:c octave:7 sharp:true duration:1.0 instrument:none)
                     [note(name:a octave:4 sharp:false duration:1.0 instrument:none)
                     note(name:b octave:2 sharp:false duration:1.0 instrument:none)
                     note(name:d octave:4 sharp:false duration:1.0 instrument:none)]
                     note(name:f octave:6 sharp:true duration:1.0 instrument:none)]
   FlatP3
in
   % Test P1 Identity
   FlatP1 = {P2T P1}
   {AssertNoteEquals FlatP1.1 ExpectedFlatP1.1 first_note_of_P1_is_incorrect}
   {AssertNoteEquals FlatP1.2.1 ExpectedFlatP1.2.1 second_note_of_P1_is_incorrect}
   {AssertNoteEquals FlatP1.2.2.1 ExpectedFlatP1.2.2.1 third_note_of_P1_is_incorrect}
   {AssertNoteEquals FlatP1.2.2.2.1 ExpectedFlatP1.2.2.2.1 fourth_note_of_P1_is_incorrect}
   {AssertNoteEquals FlatP1.2.2.2.2.1 ExpectedFlatP1.2.2.2.2.1 fifth_note_of_P1_is_incorrect}

   % Test P2 Identity
   FlatP2 = {P2T P2}
   {AssertChordEqual AssertNoteEquals FlatP2 ExpectedFlatP2}

   % Test P3 Identity
   FlatP3 = {P2T P3}
   for X in 1..{List.length FlatP3} do
      {AssertChordEqual AssertNoteEquals {List.nth FlatP3 X} {List.nth ExpectedFlatP3 X}}
   end
end

proc {TestDuration P2T}
   % Test P1 Duration
   P1 = [a duration(seconds:1.5 [b2 c#3 d])]
   ExpectedFlatP1 = [note(name:a octave:4 sharp:false duration:1.0 instrument:none)
                    note(name:b octave:2 sharp:false duration:0.5 instrument:none)
                    note(name:c octave:3 sharp:true duration:0.5 instrument:none)
                    note(name:d octave:4 sharp:false duration:0.5 instrument:none)]
   FlatP1

   % Test P2 Duration
   P2 = [b duration(seconds:0.5 [[f1 g#6]])]
   ExpectedFlatP2 = [note(name:b octave:4 sharp:false duration:1.0 instrument:none)
                    [note(name:f octave:1 sharp:false duration:0.50 instrument:none)
                    note(name:g octave:6 sharp:true duration:0.50 instrument:none)]]
   FlatP2

   % Test P3 Duration
   P3 = [duration(seconds:6.0 [drone(note:f3 amount:2) g])]
   ExpectedFlatP3 = [note(name:f octave:3 sharp:false duration:2.0 instrument:none)
                    note(name:f octave:3 sharp:false duration:2.0 instrument:none)
                    note(name:g octave:4 sharp:false duration:2.0 instrument:none)]
   FlatP3

   % Test P4 Duration
   P4 = [b#2 duration(seconds:3.0 [stretch(factor:5.0 [silence silence])])]
   ExpectedFlatP4 = [note(name:b octave:2 sharp:true duration:1.0 instrument:none)
                     silence(duration:3.0/(5.0*2.0)*5.0)
                     silence(duration:3.0/(5.0*2.0)*5.0)]
   FlatP4

   % Test P5 Duration
   P5 = [duration(seconds:4.0 [[a0 b#1] [a0 b#1]])]
   ExpectedFlatP5 = [[note(duration:2.0 instrument:none name:a octave:0 sharp:false) 
                     note(duration:2.0 instrument:none name:b octave:1 sharp:true)] 
                     [note(duration:2.0 instrument:none name:a octave:0 sharp:false) 
                     note(duration:2.0 instrument:none name:b octave:1 sharp:true)]]
   FlatP5

   % Test P6 Duration
   P6 = [duration(seconds:4.0 [nil [a0 b#1] [a0 b#1]])]
   ExpectedFlatP6 = [nil
                     [note(duration:2.0 instrument:none name:a octave:0 sharp:false) 
                     note(duration:2.0 instrument:none name:b octave:1 sharp:true)] 
                     [note(duration:2.0 instrument:none name:a octave:0 sharp:false) 
                     note(duration:2.0 instrument:none name:b octave:1 sharp:true)]]
   FlatP6
in
   % Test P1 Duration
   FlatP1 = {P2T P1}
   for X in 1..{List.length FlatP1} do
      {AssertChordEqual AssertNoteEquals {List.nth FlatP1 X} {List.nth ExpectedFlatP1 X}}
   end

   % Test P2 Duration
   FlatP2 = {P2T P2}
   for X in 1..{List.length FlatP2} do
      {AssertChordEqual AssertNoteEquals {List.nth FlatP2 X} {List.nth ExpectedFlatP2 X}}
   end

   % Test P3 Duration
   FlatP3 = {P2T P3}
   for X in 1..{List.length FlatP3} do
      {AssertChordEqual AssertNoteEquals {List.nth FlatP3 X} {List.nth ExpectedFlatP3 X}}
   end
   
   % Test P4 Duration
   FlatP4 = {P2T P4}
   for X in 1..{List.length FlatP4} do
      {AssertChordEqual AssertNoteEquals {List.nth FlatP4 X} {List.nth ExpectedFlatP4 X}}
   end

   % Test P5 Duration
   FlatP5 = {P2T P5}
   for X in 1..{List.length FlatP5} do
      {AssertChordEqual AssertNoteEquals {List.nth FlatP5 X} {List.nth ExpectedFlatP5 X}}
   end

   % Test P6 Duration
   FlatP6 = {P2T P6}
   for X in 1..{List.length FlatP6} do
      {AssertChordEqual AssertNoteEquals {List.nth FlatP6 X} {List.nth ExpectedFlatP6 X}}
   end
end

proc {TestStretch P2T}
   % Test P1 Stretch
   P1 = [a stretch(factor:2.1 [b2 c#3 d])]
   ExpectedFlatP1 = [note(name:a octave:4 sharp:false duration:1.0 instrument:none)
                    note(name:b octave:2 sharp:false duration:2.1 instrument:none)
                    note(name:c octave:3 sharp:true duration:2.1 instrument:none)
                    note(name:d octave:4 sharp:false duration:2.1 instrument:none)]
   FlatP1

   % Test P2 Stretch
   P2 = [b stretch(factor:3.7 [[f1 g#6]])]
   ExpectedFlatP2 = [note(name:b octave:4 sharp:false duration:1.0 instrument:none)
                    [note(name:f octave:1 sharp:false duration:3.7 instrument:none)
                    note(name:g octave:6 sharp:true duration:3.7 instrument:none)]]
   FlatP2

   % Test P3 Stretch
   P3 = [b stretch(factor:2.5 [[note(name:b octave:3 sharp:false duration:1.0 instrument:none) 
                              note(name:g octave:6 sharp:true duration:1.0 instrument:none)]])]
   ExpectedFlatP3 = [note(name:b octave:4 sharp:false duration:1.0 instrument:none)
                    [note(name:b octave:3 sharp:false duration:2.5 instrument:none)
                    note(name:g octave:6 sharp:true duration:2.5 instrument:none)]]
   FlatP3

   % Test P4 Stretch
   P4 = [stretch(factor:1.5 [drone(note:f3 amount:2) g])]
   ExpectedFlatP4 = [note(name:f octave:3 sharp:false duration:1.5 instrument:none)
                    note(name:f octave:3 sharp:false duration:1.5 instrument:none)
                    note(name:g octave:4 sharp:false duration:1.5 instrument:none)]
   FlatP4

   % Test P5 Stretch
   P5 = [stretch(factor:1.8 [drone(note:[note(name:f octave:4 sharp:false duration:1.0 instrument:none)
                                       note(name:d octave:2 sharp:false duration:1.0 instrument:none)
                                       note(name:e octave:5 sharp:true duration:1.0 instrument:none)
                                       note(name:e octave:1 sharp:false duration:1.0 instrument:none)] amount:2)])]
   
   ExpectedFlatP5 = [[note(name:f octave:4 sharp:false duration:1.8 instrument:none)
                     note(name:d octave:2 sharp:false duration:1.8 instrument:none)
                     note(name:e octave:5 sharp:true duration:1.8 instrument:none)
                     note(name:e octave:1 sharp:false duration:1.8 instrument:none)]
                    [note(name:f octave:4 sharp:false duration:1.8 instrument:none)
                     note(name:d octave:2 sharp:false duration:1.8 instrument:none)
                     note(name:e octave:5 sharp:true duration:1.8 instrument:none)
                     note(name:e octave:1 sharp:false duration:1.8 instrument:none)]]
   FlatP5

   % Test P6 Stretch
   P6 = [stretch(factor:1.85 [stretch(factor:2.2 [d#5]) g])]
   ExpectedFlatP6 = [note(name:d octave:5 sharp:true duration:4.07 instrument:none)
                  note(name:g octave:4 sharp:false duration:1.85 instrument:none)]
   FlatP6

   % Test P7 Stretch
   P7 = [stretch(factor:1.85 [silence silence])]
   ExpectedFlatP7 = [silence(duration:1.85)
                     silence(duration:1.85)]
   FlatP7

   % Test P8 Stretch
   P8 = [a stretch(factor:2.1 [b2 nil c#3 nil nil d])]
   ExpectedFlatP8 = [note(name:a octave:4 sharp:false duration:1.0 instrument:none)
                    note(name:b octave:2 sharp:false duration:2.1 instrument:none)
                    nil
                    note(name:c octave:3 sharp:true duration:2.1 instrument:none)
                    nil
                    nil
                    note(name:d octave:4 sharp:false duration:2.1 instrument:none)]
   FlatP8
in
   % Test P1 Stretch
   FlatP1 = {P2T P1}
   for X in 1..{List.length FlatP1} do
      {AssertChordEqual AssertNoteEquals {List.nth FlatP1 X} {List.nth ExpectedFlatP1 X}}
   end

   % Test P2 Stretch
   FlatP2 = {P2T P2}
   for X in 1..{List.length FlatP2} do
      {AssertChordEqual AssertNoteEquals {List.nth FlatP2 X} {List.nth ExpectedFlatP2 X}}
   end

   % Test P3 Stretch
   FlatP3 = {P2T P3}
   for X in 1..{List.length FlatP3} do
      {AssertChordEqual AssertNoteEquals {List.nth FlatP3 X} {List.nth ExpectedFlatP3 X}}
   end

   % Test P4 Stretch
   FlatP4 = {P2T P4}
   for X in 1..{List.length FlatP4} do
      {AssertChordEqual AssertNoteEquals {List.nth FlatP4 X} {List.nth ExpectedFlatP4 X}}
   end

   % Test P5 Stretch
   FlatP5 = {P2T P5}
   for X in 1..{List.length FlatP5} do
      {AssertChordEqual AssertNoteEquals {List.nth FlatP5 X} {List.nth ExpectedFlatP5 X}}
   end

   % Test P6 Stretch
   FlatP6 = {P2T P6}
   for X in 1..{List.length FlatP6} do
      {AssertChordEqual AssertNoteEquals {List.nth FlatP6 X} {List.nth ExpectedFlatP6 X}}
   end

   % Test P7 Stretch
   FlatP7 = {P2T P7}
   for X in 1..{List.length FlatP7} do
      {AssertChordEqual AssertNoteEquals {List.nth FlatP7 X} {List.nth ExpectedFlatP7 X}}
   end

   % Test P8 Stretch
   FlatP8 = {P2T P8}
   for X in 1..{List.length FlatP8} do
      {AssertChordEqual AssertNoteEquals {List.nth FlatP8 X} {List.nth ExpectedFlatP8 X}}
   end
end

proc {TestDrone P2T}
   % Test P1 Drone
   P1 = [drone(note:a5 amount:3) drone(note:g amount:2)]
   ExpectedFlatP1 = [note(name:a octave:5 sharp:false duration:1.0 instrument:none)
                    note(name:a octave:5 sharp:false duration:1.0 instrument:none)
                    note(name:a octave:5 sharp:false duration:1.0 instrument:none)
                    note(name:g octave:4 sharp:false duration:1.0 instrument:none)
                    note(name:g octave:4 sharp:false duration:1.0 instrument:none)]
   FlatP1

   % Test P2 Drone
   P2 = [drone(note:note(name:b octave:2 sharp:false duration:1.0 instrument:none) amount:2) 
        drone(note:f#6 amount:2) 
        drone(note:note(name:c octave:5 sharp:true duration:1.0 instrument:none) amount:3)]
   ExpectedFlatP2 = [note(name:b octave:2 sharp:false duration:1.0 instrument:none)
                    note(name:b octave:2 sharp:false duration:1.0 instrument:none)
                    note(name:f octave:6 sharp:true duration:1.0 instrument:none)
                    note(name:f octave:6 sharp:true duration:1.0 instrument:none)
                    note(name:c octave:5 sharp:true duration:1.0 instrument:none) 
                    note(name:c octave:5 sharp:true duration:1.0 instrument:none) 
                    note(name:c octave:5 sharp:true duration:1.0 instrument:none)]
   FlatP2

   % Test P3 Drone
   P3 = [drone(note:[a2 f d#5] amount:3)]
   ExpectedFlatP3 = [[note(name:a octave:2 sharp:false duration:1.0 instrument:none)
                     note(name:f octave:4 sharp:false duration:1.0 instrument:none)
                     note(name:d octave:5 sharp:true duration:1.0 instrument:none)]
                     [note(name:a octave:2 sharp:false duration:1.0 instrument:none)
                     note(name:f octave:4 sharp:false duration:1.0 instrument:none)
                     note(name:d octave:5 sharp:true duration:1.0 instrument:none)]
                     [note(name:a octave:2 sharp:false duration:1.0 instrument:none)
                     note(name:f octave:4 sharp:false duration:1.0 instrument:none)
                     note(name:d octave:5 sharp:true duration:1.0 instrument:none)]]
   FlatP3

   % Test P4 Drone
   P4 = [drone(note:b amount:2) drone(note:silence amount:2)]
   ExpectedFlatP4 = [note(name:b octave:4 sharp:false duration:1.0 instrument:none)
                    note(name:b octave:4 sharp:false duration:1.0 instrument:none)
                    silence(duration:1.0)
                    silence(duration:1.0)]
   FlatP4

   % Test P5 Drone
   P5 = [drone(note:[note(name:f octave:4 sharp:false duration:1.0 instrument:none)
              note(name:d octave:2 sharp:false duration:1.0 instrument:none)
              note(name:e octave:5 sharp:true duration:1.0 instrument:none)
              note(name:e octave:1 sharp:false duration:1.0 instrument:none)] amount:2)]

   ExpectedFlatP5 = [[note(name:f octave:4 sharp:false duration:1.0 instrument:none)
                     note(name:d octave:2 sharp:false duration:1.0 instrument:none)
                     note(name:e octave:5 sharp:true duration:1.0 instrument:none)
                     note(name:e octave:1 sharp:false duration:1.0 instrument:none)] 
                     [note(name:f octave:4 sharp:false duration:1.0 instrument:none)
                     note(name:d octave:2 sharp:false duration:1.0 instrument:none)
                     note(name:e octave:5 sharp:true duration:1.0 instrument:none)
                     note(name:e octave:1 sharp:false duration:1.0 instrument:none)]]
   FlatP5

   % Test P6 Drone
   P6 = [drone(note:[c#5 silence b] amount:2)]
   ExpectedFlatP6 = [[note(name:c octave:5 sharp:true duration:1.0 instrument:none)
                     silence(duration:1.0)
                     note(name:b octave:4 sharp:false duration:1.0 instrument:none)]
                     [note(name:c octave:5 sharp:true duration:1.0 instrument:none)
                     silence(duration:1.0)
                     note(name:b octave:4 sharp:false duration:1.0 instrument:none)]]
   FlatP6

   % Test P7 Drone
   P7 = [drone(note:[silence c#5 b] amount:2)]
   ExpectedFlatP7 = [[silence(duration:1.0)
                     note(name:c octave:5 sharp:true duration:1.0 instrument:none)
                     note(name:b octave:4 sharp:false duration:1.0 instrument:none)]
                     [silence(duration:1.0)
                     note(name:c octave:5 sharp:true duration:1.0 instrument:none)
                     note(name:b octave:4 sharp:false duration:1.0 instrument:none)]]
   FlatP7

   % Test P8 Drone
   P8 = [drone(note:[silence(duration:1.0)
               note(name:c octave:5 sharp:true duration:1.0 instrument:none)
               note(name:b octave:4 sharp:false duration:1.0 instrument:none)] amount:2)]
   ExpectedFlatP8 = [[silence(duration:1.0)
                     note(name:c octave:5 sharp:true duration:1.0 instrument:none)
                     note(name:b octave:4 sharp:false duration:1.0 instrument:none)]
                     [silence(duration:1.0)
                     note(name:c octave:5 sharp:true duration:1.0 instrument:none)
                     note(name:b octave:4 sharp:false duration:1.0 instrument:none)]]
   FlatP8

   % Test P9 Drone
   P9 = [drone(note:[note(name:c octave:5 sharp:true duration:1.0 instrument:none)
               silence(duration:1.0)
               note(name:b octave:4 sharp:false duration:1.0 instrument:none)] amount:2)]
   ExpectedFlatP9 = [[note(name:c octave:5 sharp:true duration:1.0 instrument:none)
                     silence(duration:1.0)
                     note(name:b octave:4 sharp:false duration:1.0 instrument:none)]
                     [note(name:c octave:5 sharp:true duration:1.0 instrument:none)
                     silence(duration:1.0)
                     note(name:b octave:4 sharp:false duration:1.0 instrument:none)]]
   FlatP9
in
   % Test P1 Drone
   FlatP1 = {P2T P1}
   for X in 1..{List.length FlatP1} do
      {AssertChordEqual AssertNoteEquals {List.nth FlatP1 X} {List.nth ExpectedFlatP1 X}}
   end

   % Test P2 Drone
   FlatP2 = {P2T P2}
   for X in 1..{List.length FlatP2} do
      {AssertChordEqual AssertNoteEquals {List.nth FlatP2 X} {List.nth ExpectedFlatP2 X}}
   end
   
   % Test P3 Drone
   FlatP3 = {P2T P3}
   for X in 1..{List.length FlatP3} do
      {AssertChordEqual AssertNoteEquals {List.nth FlatP3 X} {List.nth ExpectedFlatP3 X}}
   end

   % Test P4 Drone
   FlatP4 = {P2T P4}
   for X in 1..{List.length FlatP4} do
      {AssertChordEqual AssertNoteEquals {List.nth FlatP4 X} {List.nth ExpectedFlatP4 X}}
   end
   
   % Test P5 Drone
   FlatP5 = {P2T P5}
   for X in 1..{List.length FlatP5} do
      {AssertChordEqual AssertNoteEquals {List.nth FlatP5 X} {List.nth ExpectedFlatP5 X}}
   end

   % Test P6 Drone
   FlatP6 = {P2T P6}
   for X in 1..{List.length FlatP6} do
      {AssertChordEqual AssertNoteEquals {List.nth FlatP6 X} {List.nth ExpectedFlatP6 X}}
   end

   % Test P7 Drone
   FlatP7 = {P2T P7}
   for X in 1..{List.length FlatP7} do
      {AssertChordEqual AssertNoteEquals {List.nth FlatP7 X} {List.nth ExpectedFlatP7 X}}
   end

   % Test P8 Drone
   FlatP8 = {P2T P8}
   for X in 1..{List.length FlatP8} do
      {AssertChordEqual AssertNoteEquals {List.nth FlatP8 X} {List.nth ExpectedFlatP8 X}}
   end

   % Test P9 Drone
   FlatP9 = {P2T P9}
   for X in 1..{List.length FlatP9} do
      {AssertChordEqual AssertNoteEquals {List.nth FlatP9 X} {List.nth ExpectedFlatP9 X}}
   end
end

proc {TestTranspose P2T}
   % Test P1 Transpose
   P1 = [b2 transpose(semitones:4 [a4])]
   ExpectedFlatP1 = [note(name:b octave:2 sharp:false duration:1.0 instrument:none)
                    note(name:c octave:5 sharp:true duration:1.0 instrument:none)]
   FlatP1

   % Test P2 Transpose
   P2 = [transpose(semitones:10 [[b5 f2 g]])]
   ExpectedFlatP2 = [[note(name:a octave:6 sharp:false duration:1.0 instrument:none)
                    note(name:d octave:3 sharp:true duration:1.0 instrument:none)
                    note(name:f octave:5 sharp:false duration:1.0 instrument:none)]]
   FlatP2

   % Test P3 Transpose
   P3 = [f#5 transpose(semitones:~1 [d5])]
   ExpectedFlatP3 = [note(name:f octave:5 sharp:true duration:1.0 instrument:none)
                  note(name:c octave:5 sharp:true duration:1.0 instrument:none)]
   FlatP3

   % Test P4 Transpose
   P4 = [transpose(semitones:~6 [d5])]
   ExpectedFlatP4 = [note(name:g octave:4 sharp:true duration:1.0 instrument:none)]
   FlatP4

   % Test P5 Transpose
   P5 = [transpose(semitones:16 [b3])]
   ExpectedFlatP5 = [note(name:d octave:5 sharp:true duration:1.0 instrument:none)]
   FlatP5

   % Test P6 Transpose
   P6 = [transpose(semitones:1 [e2])]
   ExpectedFlatP6 = [note(name:f octave:2 sharp:false duration:1.0 instrument:none)]
   FlatP6

   % Test P7 Transpose
   P7 = [transpose(semitones:~16 [d#5])]
   ExpectedFlatP7 = [note(name:b octave:3 sharp:false duration:1.0 instrument:none)]
   FlatP7

   % Test P8 Transpose
   P8 = [transpose(semitones:~10 [stretch(factor:2.3 [d2 f#6])])]
   ExpectedFlatP8 = [note(name:e octave:1 sharp:false duration:2.3 instrument:none)
                     note(name:g octave:5 sharp:true duration:2.3 instrument:none)]
   FlatP8

   % Test P9 Transpose
   P9 = [transpose(semitones:~10 [stretch(factor:2.3 [[d2 f#6]])])]
   ExpectedFlatP9 = [[note(name:e octave:1 sharp:false duration:2.3 instrument:none)
                     note(name:g octave:5 sharp:true duration:2.3 instrument:none)]]
   FlatP9

   % Test P10 Transpose
   P10 = [transpose(semitones:~16 [d#5 nil])]
   ExpectedFlatP10 = [note(name:b octave:3 sharp:false duration:1.0 instrument:none)
                      nil]
   FlatP10
in
   % Test P1 Transpose
   FlatP1 = {P2T P1}
   for X in 1..{List.length FlatP1} do
      {AssertChordEqual AssertNoteEquals {List.nth FlatP1 X} {List.nth ExpectedFlatP1 X}}
   end

   % Test P2 Transpose
   FlatP2 = {P2T P2}
   for X in 1..{List.length FlatP2} do
      {AssertChordEqual AssertNoteEquals {List.nth FlatP2 X} {List.nth ExpectedFlatP2 X}}
   end

   % Test P3 Transpose
   FlatP3 = {P2T P3}
   for X in 1..{List.length FlatP3} do
      {AssertChordEqual AssertNoteEquals {List.nth FlatP3 X} {List.nth ExpectedFlatP3 X}}
   end

   % Test P4 Transpose
   FlatP4 = {P2T P4}
   for X in 1..{List.length FlatP4} do
      {AssertChordEqual AssertNoteEquals {List.nth FlatP4 X} {List.nth ExpectedFlatP4 X}}
   end

   % Test P5 Transpose
   FlatP5 = {P2T P5}
   for X in 1..{List.length FlatP5} do
      {AssertChordEqual AssertNoteEquals {List.nth FlatP5 X} {List.nth ExpectedFlatP5 X}}
   end

   % Test P6 Transpose
   FlatP6 = {P2T P6}
   for X in 1..{List.length FlatP6} do
      {AssertChordEqual AssertNoteEquals {List.nth FlatP6 X} {List.nth ExpectedFlatP6 X}}
   end

   % Test P7 Transpose
   FlatP7 = {P2T P7}
   for X in 1..{List.length FlatP7} do
      {AssertChordEqual AssertNoteEquals {List.nth FlatP7 X} {List.nth ExpectedFlatP7 X}}
   end

   % Test P8 Transpose
   FlatP8 = {P2T P8}
   for X in 1..{List.length FlatP8} do
      {AssertChordEqual AssertNoteEquals {List.nth FlatP8 X} {List.nth ExpectedFlatP8 X}}
   end

   % Test P9 Transpose
   FlatP9 = {P2T P9}
   for X in 1..{List.length FlatP9} do
      {AssertChordEqual AssertNoteEquals {List.nth FlatP9 X} {List.nth ExpectedFlatP9 X}}
   end

   % Test P10 Transpose
   FlatP10 = {P2T P10}
   for X in 1..{List.length FlatP10} do
      {AssertChordEqual AssertNoteEquals {List.nth FlatP10 X} {List.nth ExpectedFlatP10 X}}
   end
end

proc {TestP2TChaining P2T}
   % Test a partition with multiple transformations
   % Test P1 Chaining
   P1 = [drone(note:a5 amount:3) drone(note:g amount:2) transpose(semitones:~10 [stretch(factor:2.3 [d2 f#6])])]
   ExpectedFlatP1 = [note(name:a octave:5 sharp:false duration:1.0 instrument:none)
                  note(name:a octave:5 sharp:false duration:1.0 instrument:none)
                  note(name:a octave:5 sharp:false duration:1.0 instrument:none)
                  note(name:g octave:4 sharp:false duration:1.0 instrument:none)
                  note(name:g octave:4 sharp:false duration:1.0 instrument:none)
                  note(name:e octave:1 sharp:false duration:2.3 instrument:none)
                  note(name:g octave:5 sharp:true duration:2.3 instrument:none)]
   FlatP1

   % Test P2 Chaining
   P2 = [stretch(factor:1.85 [stretch(factor:2.2 [d#5]) g]) duration(seconds:6.0 [drone(note:f3 amount:2) g])]
   ExpectedFlatP2 = [note(name:d octave:5 sharp:true duration:4.07 instrument:none)
                    note(name:g octave:4 sharp:false duration:1.85 instrument:none)
                    note(name:f octave:3 sharp:false duration:2.0 instrument:none)
                    note(name:f octave:3 sharp:false duration:2.0 instrument:none)
                    note(name:g octave:4 sharp:false duration:2.0 instrument:none)]
   FlatP2
in
   % Test P1 Chaining
   FlatP1 = {P2T P1}
   for X in 1..{List.length FlatP1} do
      {AssertChordEqual AssertNoteEquals {List.nth FlatP1 X} {List.nth ExpectedFlatP1 X}}
   end

   % Test P2 Chaining
   FlatP2 = {P2T P2}
   for X in 1..{List.length FlatP2} do
      {AssertChordEqual AssertNoteEquals {List.nth FlatP2 X} {List.nth ExpectedFlatP2 X}}
   end
end

proc {TestEmptyChords P2T}
   % Test P1 EmptyChords
   P1 = [[silence silence]]
   ExpectedFlatP1 = [[silence(duration:1.0)
                     silence(duration:1.0)]]
   FlatP1

   % Test P2 EmptyChords
   P2 = [[silence(duration:1.0)
         silence(duration:1.0)]]
   ExpectedFlatP2 = [[silence(duration:1.0)
                     silence(duration:1.0)]]
   FlatP2

   % Test P3 EmptyChords
   P3 = [a2 nil]
   ExpectedFlatP3 = [note(name:a octave:2 sharp:false duration:1.0 instrument:none)
                     nil]
   FlatP3

   % Test P4 EmptyChords
   P4 = [a2 nil [f g#5]]
   ExpectedFlatP4 = [note(name:a octave:2 sharp:false duration:1.0 instrument:none)
                     nil
                     [note(name:f octave:4 sharp:false duration:1.0 instrument:none)
                     note(name:g octave:5 sharp:true duration:1.0 instrument:none)]]
   FlatP4

   % Test P5 EmptyChords
   P5 = [f#3 drone(note:nil amount:5) b6]
   ExpectedFlatP5 = [note(name:f octave:3 sharp:true duration:1.0 instrument:none)
                     nil
                     nil
                     nil
                     nil
                     nil
                     note(name:b octave:6 sharp:false duration:1.0 instrument:none)]
   FlatP5

   % Test P6 EmptyChords
   P6 = nil
   ExpectedFlatP6 = nil
   FlatP6

   % Test P7 EmptyChords
   P7 = [nil]
   ExpectedFlatP7 = [nil]
   FlatP7
in
   % Test P1 EmptyChords
   FlatP1 = {P2T P1}
   for X in 1..{List.length FlatP1} do
      {AssertChordEqual AssertNoteEquals {List.nth FlatP1 X} {List.nth ExpectedFlatP1 X}}
   end

   % Test P2 EmptyChords
   FlatP2 = {P2T P2}
   for X in 1..{List.length FlatP2} do
      {AssertChordEqual AssertNoteEquals {List.nth FlatP2 X} {List.nth ExpectedFlatP2 X}}
   end


   % Test P3 EmptyChords
   FlatP3 = {P2T P3}
   for X in 1..{List.length FlatP3} do
      {AssertChordEqual AssertNoteEquals {List.nth FlatP3 X} {List.nth ExpectedFlatP3 X}}
   end

   % Test P4 EmptyChords
   FlatP4 = {P2T P4}
   for X in 1..{List.length FlatP4} do
      {AssertChordEqual AssertNoteEquals {List.nth FlatP4 X} {List.nth ExpectedFlatP4 X}}
   end

   % Test P5 EmptyChords
   FlatP5 = {P2T P5}
   for X in 1..{List.length FlatP5} do
      {AssertChordEqual AssertNoteEquals {List.nth FlatP5 X} {List.nth ExpectedFlatP5 X}}
   end

   % Test P6 EmptyChords
   FlatP6 = {P2T P6}
   {AssertNilEquals FlatP6 ExpectedFlatP6 "There's a problem with the empty partition"}

   % Test P7 EmptyChords
   FlatP7 = {P2T P7}
   for X in 1..{List.length FlatP7} do
      {AssertChordEqual AssertNoteEquals {List.nth FlatP7 X} {List.nth ExpectedFlatP7 X}}
   end
end
   
proc {TestP2T P2T}
   {TestNotes P2T}
   {TestChords P2T}
   {TestIdentity P2T}
   {TestDuration P2T}
   {TestStretch P2T}
   {TestDrone P2T}
   {TestTranspose P2T}
   {TestP2TChaining P2T}
   {TestEmptyChords P2T}   
   {AssertEquals {P2T nil} nil 'nil partition'}
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TEST Mix

proc {TestSamples P2T Mix}
   skip
end

proc {TestPartition P2T Mix}
   skip
end

proc {TestWave P2T Mix}
   skip
end

proc {TestMerge P2T Mix}
   skip
end

proc {TestReverse P2T Mix}
   skip
end

proc {TestRepeat P2T Mix}
   skip
end

proc {TestLoop P2T Mix}
   skip
end

proc {TestClip P2T Mix}
   skip
end

proc {TestEcho P2T Mix}
   skip
end

proc {TestFade P2T Mix}
   skip
end

proc {TestCut P2T Mix}
   skip
end

proc {TestMix P2T Mix}
   {TestSamples P2T Mix}
   {TestPartition P2T Mix}
   {TestWave P2T Mix}
   {TestMerge P2T Mix}
   {TestReverse P2T Mix}
   {TestRepeat P2T Mix}
   {TestLoop P2T Mix}
   {TestClip P2T Mix}
   {TestEcho P2T Mix}
   {TestFade P2T Mix}
   {TestCut P2T Mix}
   {AssertEquals {Mix P2T nil} nil 'nil music'}
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

proc {Test Mix P2T}
   {Property.put print print(width:100)}
   {Property.put print print(depth:100)}
   {System.show 'tests have started'}
   {TestP2T P2T}
   {System.show 'P2T tests have run'}
   % {TestMix P2T Mix}
   % {System.show 'Mix tests have run'}
   {System.show test(passed:@PassedTests total:@TotalTests)}
end