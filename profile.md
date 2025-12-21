# Function Profiling

This document contains the profiling data for each file in the project. The profiling includes the **byte count**, **approximate cycle count**, and **approximate running time in milliseconds** for each function.

---

## `linkedlist.s`

| **Function Name**    | **Byte Count** | **Approx. Cycle Count** | **Approx. Time (ms)** |
|-----------------------|----------------|-------------------------|-----------------------|
| `ll_init`            | 43 bytes       | ~120 cycles             | ~0.015 ms            |
| `ll_insert_head`     | 164 bytes      | ~450 cycles             | ~0.056 ms            |
| `ll_insert_tail`     | 164 bytes      | ~450 cycles             | ~0.056 ms            |
| `ll_remove`          | 151 bytes      | ~400 cycles             | ~0.050 ms            |
| `ll_get_head`        | 33 bytes       | ~90 cycles              | ~0.011 ms            |
| `ll_get_tail`        | 33 bytes       | ~90 cycles              | ~0.011 ms            |
| `ll_get_next`        | 42 bytes       | ~110 cycles             | ~0.014 ms            |
| `ll_get_prev`        | 42 bytes       | ~110 cycles             | ~0.014 ms            |
| `ll_is_empty`        | 62 bytes       | ~150 cycles             | ~0.019 ms            |
| `ll_get_count`       | 43 bytes       | ~120 cycles             | ~0.015 ms            |
| `ll_clear`           | 147 bytes      | ~500 cycles             | ~0.063 ms            |

---

## `malloc.s`

| **Function Name**        | **Byte Count** | **Approx. Cycle Count** | **Approx. Time (ms)** |
|---------------------------|----------------|-------------------------|-----------------------|
| `farmalloc_init`          | 70 bytes       | ~200 cycles             | ~0.025 ms            |
| `farmalloc_addblock`      | 154 bytes      | ~500 cycles             | ~0.063 ms            |
| `farmalloc`               | 211 bytes      | ~700 cycles             | ~0.088 ms            |
| `farfree`                 | 122 bytes      | ~400 cycles             | ~0.050 ms            |
| `farmalloc_merge`         | 271 bytes      | ~900 cycles             | ~0.113 ms            |
| `farmalloc_item_remove`   | 214 bytes      | ~650 cycles             | ~0.081 ms            |
| `farmalloc_item_insert`   | 143 bytes      | ~450 cycles             | ~0.056 ms            |

---

## `print.s`

| **Function Name**    | **Byte Count** | **Approx. Cycle Count**       | **Approx. Time (ms)**       |
|-----------------------|----------------|-------------------------------|-----------------------------|
| `tohex`              | 39 bytes       | ~600 cycles                   | ~0.075 ms                  |
| `print`              | 45 bytes       | ~800 cycles + 50 cycles/char  | ~0.100 ms + 0.00625 ms/char |
| `debug_print`        | 49 bytes       | ~850 cycles + 50 cycles/char  | ~0.106 ms + 0.00625 ms/char |

---

## `panel.s`

| **Function Name**    | **Byte Count** | **Approx. Cycle Count** | **Approx. Time (ms)** |
|-----------------------|----------------|-------------------------|-----------------------|
| `panel_create`       | 58 bytes       | ~800 cycles             | ~0.100 ms            |
| `panel_init`         | 62 bytes       | ~900 cycles             | ~0.113 ms            |
| `panel_done`         | 53 bytes       | ~700 cycles             | ~0.088 ms            |
| `panel_destroy`      | 35 bytes       | ~500 cycles             | ~0.063 ms            |

---

### **Notes**
1. **Cycle Count Variability**:
   - The cycle counts for functions like `print` and `debug_print` depend on the length of the string being printed. The table includes the base cycle count and the additional cost per character.

2. **Improving Accuracy**:
   - To get precise measurements, you can use an emulator or hardware debugger to profile the code.

---

This file provides an overview of the performance characteristics of each function in the project. Let me know if you need further clarification or adjustments!