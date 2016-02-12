averages_data = ddply(dataset, c("Subject","Activity"), numcolwise(mean))
write.table(averages_data, file = "averages_data.txt")
