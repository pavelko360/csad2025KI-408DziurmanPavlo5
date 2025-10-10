#include <gtest/gtest.h>
#include "../math_operations.h"

TEST(AddFunctionTest, PositiveNumbers) {
    EXPECT_EQ(add(3, 7), 10);
}

TEST(AddFunctionTest, NegativeNumbers) {
    EXPECT_EQ(add(-2, -2), -4);
}

TEST(AddFunctionTest, NegativeAndPositive) {
    EXPECT_EQ(add(-1, 1), 0);
}

int main(int argc, char** argv) {
    ::testing::InitGoogleTest(&argc, argv);
    return RUN_ALL_TESTS();
}