#include <iostream>
#include <memory>
#include <vector>

// This file contains intentional issues that cppcheck should detect

// another test
void testMemoryLeaks() {
  // Memory leak - allocated but never freed
  int* ptr = new int[100];
  // Missing delete[] ptr;

  // Double allocation without freeing
  ptr = new int[200];
  delete[] ptr; // Only frees the second allocation
}

void testNullPointerDereference() {

  int* ptr = nullptr;

  // Null pointer dereference - cppcheck should catch this
  *ptr = 42;

  // Another potential null dereference
  int* ptr2 = new int(10);
  delete ptr2;
  ptr2 = nullptr;
  const int test = 4;
  int anotherTest = 4;
  std::cout << test << std::endl;
  std::cout << anotherTest << std::endl;
  std::cout << *ptr2 << std::endl; // Using after setting to nullptr
}

void testArrayOutOfBounds() {
  int arr[5] = {1, 2, 3, 4, 5};

  // Array out of bounds access - cppcheck should catch this
  arr[10] = 99;

  // Another out of bounds
  for(int i = 0; i <= 5; ++i) { // Should be i < 5
    arr[i] = i;
  }
}

void testUninitializedVariable() {
  int x; // Uninitialized variable

  // Using uninitialized variable - cppcheck should catch this
  std::cout << "Value: " << x << std::endl;

  // Another uninitialized usage
  int y;
  int z = y + 10; // Using uninitialized y
}

void testUnusedVariable() {
  int unused_var = 42; // Unused variable - cppcheck should catch this
  int used_var = 10;

  std::cout << "Used: " << used_var << std::endl;
  // unused_var is never used
}

void testDivisionByZero() {
  int divisor = 0;
  int result = 100 / divisor; // Division by zero - cppcheck should catch this

  std::cout << "Result: " << result << std::endl;
}

void testResourceLeaks() {
  // File handle leak
  FILE* file = fopen("test.txt", "r");
  // Missing fclose(file);

  // Another resource issue
  std::unique_ptr<int[]> ptr1(new int[100]);
  int* raw_ptr = ptr1.release(); // Resource management issue
                                 // raw_ptr is never freed
}

void testLogicalErrors() {
  // Logical error - condition always false
  int x = 5;
  if(x > 10 && x < 2) {
    std::cout << "This will never execute" << std::endl;
  }

  // Another logical issue
  bool flag = true;
  if(flag = false) { // Assignment instead of comparison
    std::cout << "This might not be intended" << std::endl;
  }
}

void testBufferOverflow() {
  char buffer[10];

  // Potential buffer overflow - cppcheck should catch this
  strcpy(buffer, "This string is way too long for the buffer");

  // Another buffer issue
  char small_buf[5];
  snprintf(small_buf, 20, "Too long"); // Size mismatch
}

int main() {
  // Call functions to make sure they're not optimized away
  testMemoryLeaks();
  testNullPointerDereference();
  testArrayOutOfBounds();
  testUninitializedVariable();
  testUnusedVariable();
  testDivisionByZero();
  testResourceLeaks();
  testLogicalErrors();
  testBufferOverflow();

  return 0;
}
