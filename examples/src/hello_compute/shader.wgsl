@group(0)
@binding(0)
var<storage, read_write> v_indices: array<u32>; // this is used as both input and output for convenience

// The Collatz Conjecture states that for any integer n:
// If n is even, n = n/2
// If n is odd, n = 3n+1
// And repeat this process for each new n, you will always eventually reach 1.
// Though the conjecture has not been proven, no counterexample has ever been found.
// This function returns how many times this recurrence needs to be applied to reach 1.
fn collatz_iterations(n_base: u32) -> u32{
    var n: u32 = n_base;
    var i: u32 = 0u;
    loop {
        if (n <= 1u) {
            break;
        }
        if (n % 2u == 0u) {
            n = n / 2u;
        }
        else {
            // Overflow? (i.e. 3*n + 1 > 0xffffffffu?)
            if (n >= 1431655765u) {   // 0x55555555u
                return 4294967295u;   // 0xffffffffu
            }

            n = 3u * n + 1u;
        }
        i = i + 1u;
    }
    return i;
}

@compute
@workgroup_size(1)
fn main(@builtin(global_invocation_id) global_id: vec3<u32>) {
    v_indices[global_id.x] = collatz_iterations(v_indices[global_id.x]);

    // Uncomment the following code to see the bug [1]
//    let test_bool = true;
//    var value_that_gets_assigned_wrong_type: array<u32, 16>;
//    if test_bool {
//        value_that_gets_assigned_wrong_type = v_indices[0];
//    }

//    This shows the following error:
//    thread 'main' panicked at wgpu/src/backend/wgpu_core.rs:1009:30:
//    wgpu error: Validation Error
//
//    Caused by:
//      In Device::create_shader_module, label = 'shader.wgsl'
//
//    Shader validation error: Entry point main at Compute is invalid
//       ┌─ shader.wgsl:43:47
//       │
//    43 │         value_that_gets_assigned_wrong_type = v_indices[0];
//       │                                               ^^^^^^^^^^^^ naga::Expression [13]
//       │
//       = The type of [13] doesn't match the type stored in [10]
//
//
//          Entry point main at Compute is invalid
//            The type of [13] doesn't match the type stored in [10]
//
//    It is however unclear what [10] is, since it is never defined in the message.


    // Uncomment the following to see the bug [2]
//    var value_that_gets_assigned_wrong_type: array<u32, 16>;
//    var wrong_type: array<u32, 8>;
//    value_that_gets_assigned_wrong_type = wrong_type;

//    This shows the following error:
//    thread 'main' panicked at wgpu/src/backend/wgpu_core.rs:1009:30:
//    wgpu error: Validation Error
//
//    Caused by:
//      In Device::create_shader_module, label = 'shader.wgsl'
//
//    Shader validation error: Entry point main at Compute is invalid
//     = The type of [11] doesn't match the type stored in [9]
//
//
//          Entry point main at Compute is invalid
//            The type of [11] doesn't match the type stored in [9]
//
//    In this case, it is unclear what both [9] and [11] are, since it is never defined in the error.
}
