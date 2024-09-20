// module Example {
//     struct SubTypeA { val: u64 }
//     struct AnotherSubTypeA { val: u64 }

//     struct SubTypeB { val: u64 }
//     struct AnotherSubTypeB { val: u64 }

//     public fun example(a2b: bool) {
//         // Define the variables for the types
//         let a;
//         let b;

//         // Conditional logic to assign values to `a` and `b`
//         if (a2b) {
//             a = SubTypeA { val: 10 };
//             b = SubTypeB { val: 20 };
//         } else {
//             a = AnotherSubTypeA { val: 30 };
//             b = AnotherSubTypeB { val: 40 };
//         }

//         // Now `a` and `b` hold different subtypes based on the condition
//     }
// }
