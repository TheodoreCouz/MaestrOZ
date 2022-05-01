PassedTests = {Cell.new 0}
TotalTests  = {Cell.new 0}

% Time in seconds corresponding to 5 samples.
FiveSamples = 0.00011337868

% Takes a list of samples, round them to 3 decimal places and multiply them by
% 10000. Use this to compare list of samples to avoid floating-point rounding
% errors.
fun {Normalize Samples}
   {Map Samples fun {$ S} {IntToFloat {FloatToInt S*1000.0}} end}
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

Correct = {Cell.new 0.0}
Total = {Cell.new 0.0}

fun {Approx A B Eps}
   case A#B of nil#nil then
      local 
         Ratio = (@Correct / @Total)
      in
         Correct := 0.0
         Total := 0.0
         Ratio
      end
   else 
      case A of nil then
          Total := @Total + 1.0
          {Approx nil B.2 Eps}
      else 
         case B of nil then
            Total := @Total + 1.0
            {Approx A.2 nil Eps}
         else
            if {Abs (A.1 - B.1)} > Eps then
               Total := @Total + 1.0
               {Approx A.2 B.2 Eps}
            else 
               Total := @Total + 1.0
               Correct := @Correct + 1.0
               {Approx A.2 B.2 Eps}
            end
         end
      end
   end
end

% Prevent warnings if these are not used.
{ForAll [FiveSamples Normalize Assert AssertEquals] Wait}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TEST PartitionToTimedNotes

proc {TestNotes P2T}
   local
      Partition = [silence c4 d4 e4 f4 g4 a4 b4]
      PartitionExtended = {P2T Partition}
      Expected = [
         silence(duration:1.0)
         note(duration:1.0 instrument:none sharp:false name:c octave:4)
         note(duration:1.0 instrument:none sharp:false name:d octave:4)
         note(duration:1.0 instrument:none sharp:false name:e octave:4)
         note(duration:1.0 instrument:none sharp:false name:f octave:4)
         note(duration:1.0 instrument:none sharp:false name:g octave:4)
         note(duration:1.0 instrument:none sharp:false name:a octave:4)
         note(duration:1.0 instrument:none sharp:false name:b octave:4)
      ]  
   in
      {AssertEquals PartitionExtended Expected 'TestNotes Failed'}
   end
end

proc {TestChords P2T}
   local
      Partition = [[silence c4 e4 f4] a4]
      PartitionExtended = {P2T Partition}
      Expected = [
         [
         silence(duration:1.0)
         note(duration:1.0 instrument:none sharp:false name:c octave:4)
         note(duration:1.0 instrument:none sharp:false name:e octave:4)
         note(duration:1.0 instrument:none sharp:false name:f octave:4)
         ]
         note(duration:1.0 instrument:none sharp:false name:a octave:4)
      ]  
   in
      {AssertEquals PartitionExtended Expected 'TestChord Failed'}
   end
end

proc {TestIdentity P2T}
   % test that extended notes and chord go from input to output unchanged
   local
      Expected = [
            [
            note(duration:1.0 instrument:none sharp:false name:c octave:4)
            note(duration:1.0 instrument:none sharp:false name:e octave:4)
            note(duration:1.0 instrument:none sharp:false name:f octave:4)
            ]
            note(duration:1.0 instrument:none sharp:false name:a octave:4)
            silence(duration:2.0)
         ]
      Processed = {P2T Expected}
   in
      {AssertEquals Processed Expected 'TestIdentity Failed'}
   end
end

proc {TestDuration P2T}
   local
      Partition = [duration(seconds:9.0 [a4 silence [a4 b4]])]
      PartitionExtended = {P2T Partition}
      Expected = [
         note(duration:3.0 instrument:none sharp:false name:a octave:4)
         silence(duration:3.0)
         [
            note(duration:3.0 instrument:none sharp:false name:a octave:4)
            note(duration:3.0 instrument:none sharp:false name:b octave:4)
         ]
      ]
   in
      {AssertEquals PartitionExtended Expected 'TestDuration Failed'}
   end
end

proc {TestStretch P2T}
   local
      Partition = [stretch(factor:2.0 [a4 silence [a4 b4]])]
      PartitionExtended = {P2T Partition}
      Expected = [
         note(duration:2.0 instrument:none sharp:false name:a octave:4)
         silence(duration:2.0)
         [
            note(duration:2.0 instrument:none sharp:false name:a octave:4)
            note(duration:2.0 instrument:none sharp:false name:b octave:4)
         ]
      ]

      P1 = {P2T [stretch(factor:0.5 [stretch(factor:0.5 [a4])])]}
      E1 = [note(duration:0.25 instrument:none sharp:false name:a octave:4)]
   in
      {AssertEquals PartitionExtended Expected 'TestStretch Failed'}
      {AssertEquals P1 E1 'TestStretch P1E1 Failed'}
   end
end

proc {TestDrone P2T}
   local
      Partition = [drone(amount:2 note:[a4 b4]) drone(amount:2 note:a4)]
      PartitionExtended = {P2T Partition}
      Expected = [
         [
            note(duration:1.0 instrument:none sharp:false name:a octave:4)
            note(duration:1.0 instrument:none sharp:false name:b octave:4)
         ]
         [
            note(duration:1.0 instrument:none sharp:false name:a octave:4)
            note(duration:1.0 instrument:none sharp:false name:b octave:4)
         ]
         note(duration:1.0 instrument:none sharp:false name:a octave:4)
         note(duration:1.0 instrument:none sharp:false name:a octave:4)
      ]
   in
      {AssertEquals PartitionExtended Expected 'TestDrone Failed'}
   end
end

proc {TestTranspose P2T}
   local
      P1 = {P2T [transpose(semitones:0 [a4 [a4 b4] silence])]}
      E1 = [
         note(duration:1.0 instrument:none sharp:false name:a octave:4)

         [
            note(duration:1.0 instrument:none sharp:false name:a octave:4)
            note(duration:1.0 instrument:none sharp:false name:b octave:4)
         ]
         silence(duration:1.0)
      ]

      P2 = {P2T [transpose(semitones:5 [a4 [a4 b4] silence])]}
      E2 = [
         note(duration:1.0 instrument:none sharp:false name:d octave:5)

         [
            note(duration:1.0 instrument:none sharp:false name:d octave:5)
            note(duration:1.0 instrument:none sharp:false name:e octave:5)
         ]
         silence(duration:1.0)
      ]
   in
      {AssertEquals P1 E1 'TestTranspose Failed 1'}
      {AssertEquals P2 E2 'TestTranspose Failed 2'}
   end
end

proc {TestNil P2T}
   local
      Partition = [f#3 drone(note:nil amount:5) b6]
      PartitionExtended = {P2T Partition}
      Expected = [note(name:f octave:3 sharp:true duration:1.0 instrument:none)
                  nil
                  nil
                  nil
                  nil
                  nil
      note(name:b octave:6 sharp:false duration:1.0 instrument:none)]
   in
      {AssertEquals PartitionExtended Expected 'TestNil Failed'}
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
   {TestNil P2T}
   {AssertEquals {P2T nil} nil 'nil partition'}
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TEST Mix

proc {TestSamples P2T Mix}
   local 
      P1 = [samples([1.0 1.0 1.0])]
      Processed = {Mix P2T P1}

      P2 = {Mix P2T [nil samples([1.0 1.0 1.0])]}
   in
      {AssertEquals Processed [1.0 1.0 1.0] 'TestSamples Failed'}
      {AssertEquals P2 [1.0 1.0 1.0] 'TestSamples Failed'}
   end
end

% proc {TestPartition P2T Mix}
%    skip
% end

proc {TestWave P2T Mix}
   local
      E1 = {Mix P2T [partition([stretch(factor:2.0 [a4])])]}
      P1 = {Mix P2T [wave('a4.wav')]}

      P2 = {Mix P2T [nil wave('a4.wav')]}
   in
      {AssertEquals {Approx P1 E1 2.0}>0.95 true 'TestWave Failed'}
      {AssertEquals {Approx P2 E1 2.0}>0.95 true 'TestWave Failed'}
   end
end

proc {TestMerge P2T Mix}
   local
      E1 = [1.0 2.0 4.0]
      P1 = {Mix P2T [merge([0.5#[samples([1.0 2.0 4.0])] 0.5#[samples([1.0 2.0 4.0])]])]}

      E2 = [
         (0.3*7.0 + 0.1 + 0.6*87.0) 
         (0.3*8.0 + 0.2 + 2.4)
         (0.3 + 0.4 + 1.8)
         ]
      P2 = {Mix P2T [merge([0.3#[samples([7.0 8.0 1.0])] 0.1#[samples([1.0 2.0 4.0])] 0.6#[samples([87.0 4.0 3.0])]])]}

      P3 = {Mix P2T [merge([nil 1.0#[samples([1.0 2.0 4.0])]])]}
      E3 = [1.0 2.0 4.0]
   in
      {AssertEquals P1 E1 'TestMerge Failed 1'}
      {AssertEquals {Approx P1 E1 1.0}>0.95 true 'TestMerge Failed 2'}
      {AssertEquals {Approx P1 E1 1.0}>0.95 true 'TestMerge Failed 3'}
   end
end

proc {TestReverse P2T Mix}
   local 
      P1 = {Mix P2T [reverse([samples([1.0 2.0 3.0])])]}
      E1 = [3.0 2.0 1.0]

      P2 = {Mix P2T [reverse([nil samples([1.0 2.0 3.0])])]}
   in
      {AssertEquals P1 E1 'TestReverse Failed'}
      {AssertEquals P2 E1 'TestReverse Failed'}
   end
end

proc {TestRepeat P2T Mix}
   local
      P1 = {Mix P2T [repeat(amount:2 [partition([a b c])])]}
      E1 = {Mix P2T [partition([a b c a b c])]}

      P2 = {Mix P2T [repeat(amount:2 [partition([a drone(amount:2 note:d) b c])])]}
      E2 = {Mix P2T [partition([a drone(amount:2 note:d) b c a drone(amount:2 note:d) b c])]}

      P3 = {Mix P2T [repeat(amount:2 [partition([a nil c])])]}
      E3 = {Mix P2T [partition([a nil c a nil c])]}
   in
      {AssertEquals P1 E1 'TestRepeat Failed 1'}
      {AssertEquals P2 E2 'TestRepeat Failed 2'}
      {AssertEquals P3 E3 'TestRepeat Failed 3'}
   end
end

proc {TestLoop P2T Mix}
   local
      P1 = [loop(seconds:6.0 [partition([a4 c4 d4 e4])])]
      E1 = {Mix P2T [partition([a4 c4 d4 e4 a4 c4])]}
      Processed = {Mix P2T P1}
      Ratio1 = {Approx {Normalize Processed} {Normalize E1} 2.0}
   in
      {AssertEquals Ratio1>0.95 true 'TestLoop Failed Ratio='#Ratio1}
   end
end

proc {TestClip P2T Mix}
   local
      E1 = [0.5 ~0.5 0.0]
      P1 = {Mix P2T [clip(low:~0.5 high:0.5 [samples([1.0 ~1.0 0.0])])]}

      P2 = {Mix P2T [nil clip(low:~0.5 high:0.5 [samples([1.0 ~1.0 0.0])])]}
   in
      {AssertEquals P1 E1 'TestClip Failed'}
      {AssertEquals P2 E1 'TestClip Failed'}
   end
end

proc {TestEcho P2T Mix}
   skip
end

proc {TestFade P2T Mix}
   skip
end

proc {TestCut P2T Mix}
   local
      P1 = {Mix P2T [cut(start:0.0 finish:4.0 [partition([a4 c4 d4 e4 f4])])]}
      E1 = {Mix P2T [partition([a4 c4 d4 e4])]}
      Ratio1 = {Approx {Normalize P1} {Normalize E1} 2.0}

      P2 = {Mix P2T [nil cut(start:0.0 finish:4.0 [partition([nil a4 c4 d4 e4 f4])])]}
      Ratio2 = {Approx {Normalize P2} {Normalize E1} 2.0}
   in
      {AssertEquals Ratio1>0.95 true 'TestCut Failed Ratio='#Ratio1}
      {AssertEquals Ratio2>0.95 true 'TestCut Failed Ratio='#Ratio2}
   end
end

proc {TestMix P2T Mix}
   {TestSamples P2T Mix}
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
   {System.show '--------------------------------------------'}
   {Property.put print print(width:100)}
   {Property.put print print(depth:100)}
   {System.show 'tests have started'}
   {TestP2T P2T}
   {System.show 'P2T tests have run'}
   {TestMix P2T Mix}
   {System.show 'Mix tests have run'}
   {System.show test(passed:@PassedTests total:@TotalTests)}
end