--
-- Table structure for table `user_collectables`
--
CREATE TABLE `user_collectables` (
    `identifier` varchar(50) NOT NULL,
    `letter_scraps` text NOT NULL,
    `sub_parts` text NOT NULL,
    `spaceship_parts` text NOT NULL,
    `hidden_packages` text NOT NULL,
    `nuclear_waste` text NOT NULL,
    `epsilon_tracts` text NOT NULL
);

--
-- Indexes for table `user_collectables`
--
ALTER TABLE `user_collectables`
ADD PRIMARY KEY (`identifier`);