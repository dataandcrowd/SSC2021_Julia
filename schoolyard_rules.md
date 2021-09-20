# Rules for Schoolyard

It's lunchtime, and the students are going out to play. We assume the school building is in the centre of our space, with some fences around the building. A teacher monitors the students, and makes sure they don't stray too far towards the fence. 

- We use a `teacher_attractor` force to simulate a teacher's attentiveness. Students head out to the schoolyard in random directions, but adhere to some social norms.
- Each student has one friend and one foe. 
  These are chosen at random in our model, so it's possible that for any pair of students, one likes the other but this feeling is not reciprocated.
- The bond between pairs is chosen at random between 0 and 1, with a bond of 1 being the strongest. 
- If the bond is friendly, agents wish above all else to be near their friend (force is `positive`). Bonds that are unfriendly see students moving as far away as possible from their foe (force is `negative`).