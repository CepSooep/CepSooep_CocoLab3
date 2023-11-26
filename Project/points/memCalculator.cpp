#include <iostream>
#include <bitset>

int main() {
    int x, y;
    
    while (true){
    std::cout << "Enter x (8 bits): ";
    std::cin >> x;

    std::cout << "Enter y (7 bits): ";
    std::cin >> y;

    // Ensure x and y fit within the specified bit ranges
    x &= 0xFF; // Limit x to 8 bits
    y &= 0x7F; // Limit y to 7 bits

    // Constructing the 16-bit value
    int result = (1 << 15) | (x << 7) | y;

    // Displaying in binary
    std::bitset<16> binaryResult(result);
    std::cout << "Result in binary: " << binaryResult << std::endl;

    // Displaying in decimal
    std::cout << "Result in decimal: " << result << std::endl;
    }
    return 0;
}
