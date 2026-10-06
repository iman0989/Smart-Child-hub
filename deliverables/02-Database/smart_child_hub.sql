-- MariaDB dump 10.19  Distrib 10.4.32-MariaDB, for Win64 (AMD64)
--
-- Host: localhost    Database: smart_child_hub
-- ------------------------------------------------------
-- Server version	10.4.32-MariaDB

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `activities`
--

DROP TABLE IF EXISTS `activities`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `activities` (
  `id` char(36) NOT NULL,
  `child_id` char(36) NOT NULL,
  `title` varchar(160) NOT NULL,
  `icon` varchar(40) NOT NULL DEFAULT 'sparkle',
  `category` varchar(80) NOT NULL DEFAULT 'Routine',
  `time` varchar(16) NOT NULL DEFAULT '',
  `coins` int(10) unsigned NOT NULL DEFAULT 5,
  `status` enum('pending','completed','inProgress','locked') NOT NULL DEFAULT 'pending',
  `activity_date` date NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_activities_child_date` (`child_id`,`activity_date`),
  CONSTRAINT `fk_activities_child` FOREIGN KEY (`child_id`) REFERENCES `children` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `activities`
--

LOCK TABLES `activities` WRITE;
/*!40000 ALTER TABLE `activities` DISABLE KEYS */;
INSERT INTO `activities` VALUES ('0636ebe0-a71d-4bdd-89bc-f491a30827ea','256ad462-d191-49e2-b671-606fbec688da','Make the bed','bed','Morning routine','7:20 AM',5,'completed','2026-08-06','2026-08-06 18:21:16','2026-08-06 18:21:16'),('0cbd2af8-e34e-42c5-874a-d75fa1acd5b7','256ad462-d191-49e2-b671-606fbec688da','Outdoor play','run','Learning & fun','5:00 PM',10,'pending','2026-08-06','2026-08-06 18:21:16','2026-08-06 18:21:16'),('0f3327ef-73f4-46ad-9010-033f3ae16518','256ad462-d191-49e2-b671-606fbec688da','Evening shower','water','Evening routine','8:00 PM',5,'locked','2026-08-06','2026-08-06 18:21:16','2026-08-06 18:21:16'),('5f4fffc9-d8ad-47c0-8af7-f53685969efe','256ad462-d191-49e2-b671-606fbec688da','Homework','homework','Learning & fun','6:00 PM',15,'pending','2026-08-06','2026-08-06 18:21:16','2026-08-06 18:21:16'),('c1a528cf-f496-412c-86b3-98e8b36270de','4b889e93-d3fd-437b-8af6-85f8dd0f024d','Pending task','sparkle','Routine','',10,'completed','2026-08-06','2026-08-06 20:15:14','2026-08-06 20:15:14'),('d038fc81-02ae-4352-b310-6a180889fc2a','6d89c02e-6f51-426f-bb25-06161c367e76','Pending task','sparkle','Routine','',10,'completed','2026-08-06','2026-08-06 20:11:52','2026-08-06 20:11:52'),('ef48c8d9-9c14-40a1-9be2-8fb2578b4482','256ad462-d191-49e2-b671-606fbec688da','Reading time','book','Learning & fun','4:00 PM',10,'pending','2026-08-06','2026-08-06 18:21:16','2026-08-06 18:21:16'),('f78a6f0e-4db5-4649-ad35-f7709f11ed73','256ad462-d191-49e2-b671-606fbec688da','Breakfast','food','Morning routine','7:45 AM',5,'completed','2026-08-06','2026-08-06 18:21:16','2026-08-06 18:21:16'),('fa7e6aee-627d-49db-81f9-764044e2bc8a','256ad462-d191-49e2-b671-606fbec688da','Brush teeth','sparkle','Morning routine','7:00 AM',5,'completed','2026-08-06','2026-08-06 18:21:16','2026-08-06 18:21:16');
/*!40000 ALTER TABLE `activities` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `attendance`
--

DROP TABLE IF EXISTS `attendance`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `attendance` (
  `id` char(36) NOT NULL,
  `child_id` char(36) NOT NULL,
  `date` date NOT NULL,
  `status` enum('present','absent','late') NOT NULL DEFAULT 'present',
  `class_name` varchar(120) NOT NULL DEFAULT 'School',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_attendance_child_date` (`child_id`,`date`),
  CONSTRAINT `fk_attendance_child` FOREIGN KEY (`child_id`) REFERENCES `children` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `attendance`
--

LOCK TABLES `attendance` WRITE;
/*!40000 ALTER TABLE `attendance` DISABLE KEYS */;
INSERT INTO `attendance` VALUES ('37c0ed79-23b9-43b0-b8b2-15d716027741','256ad462-d191-49e2-b671-606fbec688da','2026-07-29','present','Grade 2 - Room 4','2026-08-06 18:21:16'),('3ee01928-5aa9-4d4c-9e40-bd9afc5ba8c3','256ad462-d191-49e2-b671-606fbec688da','2026-07-28','present','Grade 2 - Room 4','2026-08-06 18:21:16'),('4a3d5c0a-f228-4386-a9f0-6a3db26038e5','256ad462-d191-49e2-b671-606fbec688da','2026-07-23','present','Grade 2 - Room 4','2026-08-06 18:21:16'),('578cc4fc-8ab0-4d34-a3ae-3d9e4536506a','256ad462-d191-49e2-b671-606fbec688da','2026-07-20','present','Grade 2 - Room 4','2026-08-06 18:21:16'),('57b7f75a-ed50-4663-8bf6-3bfc6deacd15','256ad462-d191-49e2-b671-606fbec688da','2026-08-05','present','Grade 2 - Room 4','2026-08-06 18:21:16'),('8216d2a2-b3d0-4a53-b2a1-ed27e59478cd','256ad462-d191-49e2-b671-606fbec688da','2026-08-04','present','Grade 2 - Room 4','2026-08-06 18:21:16'),('8496c3dc-5b84-40ec-b4ae-61d7bba58b1b','256ad462-d191-49e2-b671-606fbec688da','2026-07-10','present','Grade 2 - Room 4','2026-08-06 18:21:16'),('8804b038-62e0-46e5-ab10-16aa95a491e4','256ad462-d191-49e2-b671-606fbec688da','2026-07-13','present','Grade 2 - Room 4','2026-08-06 18:21:16'),('96d9d2ad-2613-41ea-8ecb-18aabdd2d4a1','256ad462-d191-49e2-b671-606fbec688da','2026-07-24','present','Grade 2 - Room 4','2026-08-06 18:21:16'),('abf87272-727a-4ef9-a12c-b07a95e0f499','256ad462-d191-49e2-b671-606fbec688da','2026-07-30','present','Grade 2 - Room 4','2026-08-06 18:21:16'),('ba9acd50-a71d-4f6b-b236-402d419fa7f0','256ad462-d191-49e2-b671-606fbec688da','2026-07-21','present','Grade 2 - Room 4','2026-08-06 18:21:16'),('be2ea22d-1c29-4134-bf43-16e12fa9fba8','256ad462-d191-49e2-b671-606fbec688da','2026-07-27','present','Grade 2 - Room 4','2026-08-06 18:21:16'),('c168754a-7ebd-4590-8e8d-9859aa66c5e1','256ad462-d191-49e2-b671-606fbec688da','2026-07-22','present','Grade 2 - Room 4','2026-08-06 18:21:16'),('c3f96845-4271-426e-a6de-92052d41d111','256ad462-d191-49e2-b671-606fbec688da','2026-07-31','present','Grade 2 - Room 4','2026-08-06 18:21:16'),('ce129689-f965-4393-a3a9-3fdb39af5346','256ad462-d191-49e2-b671-606fbec688da','2026-07-17','present','Grade 2 - Room 4','2026-08-06 18:21:16'),('d5e58f7c-785d-47a7-95d9-ba5762a72f49','256ad462-d191-49e2-b671-606fbec688da','2026-07-14','present','Grade 2 - Room 4','2026-08-06 18:21:16'),('d88f022d-3385-495a-a0df-d4ae35eba921','256ad462-d191-49e2-b671-606fbec688da','2026-07-15','present','Grade 2 - Room 4','2026-08-06 18:21:16'),('ee42d7df-2005-4baa-bdc4-592434d3c08a','256ad462-d191-49e2-b671-606fbec688da','2026-08-03','present','Grade 2 - Room 4','2026-08-06 18:21:16'),('f13ce63b-c252-4c6d-b4fd-b3c6e4877eba','256ad462-d191-49e2-b671-606fbec688da','2026-08-06','present','Grade 2 - Room 4','2026-08-06 18:21:16'),('f3f60bed-a85d-451a-9889-317dda6ccf18','256ad462-d191-49e2-b671-606fbec688da','2026-07-16','present','Grade 2 - Room 4','2026-08-06 18:21:16');
/*!40000 ALTER TABLE `attendance` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `auth_tokens`
--

DROP TABLE IF EXISTS `auth_tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `auth_tokens` (
  `id` char(36) NOT NULL,
  `parent_id` char(36) NOT NULL,
  `token_hash` char(64) NOT NULL,
  `device_name` varchar(120) NOT NULL DEFAULT 'mobile',
  `expires_at` datetime NOT NULL,
  `last_used_at` datetime DEFAULT NULL,
  `revoked` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_auth_tokens_hash` (`token_hash`),
  KEY `idx_auth_tokens_parent` (`parent_id`),
  CONSTRAINT `fk_auth_tokens_parent` FOREIGN KEY (`parent_id`) REFERENCES `parents` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auth_tokens`
--

LOCK TABLES `auth_tokens` WRITE;
/*!40000 ALTER TABLE `auth_tokens` DISABLE KEYS */;
INSERT INTO `auth_tokens` VALUES ('0127064a-9036-4d35-8a1a-c2a1f1e1ddde','af582e85-1503-448e-ba2b-272f3a3b6cd4','79cbe307f761c6fcc0b05bb547c107963095e9924fcbdd26873627053d63ba55','mobile','2026-09-06 15:23:21','2026-08-07 16:23:40',1,'2026-08-07 13:23:21'),('0164f1c4-6ea1-48d7-94ea-699d96d07a6c','2db5d16d-bca8-460b-a87d-df7c47f9bbe4','79424704c70288338a9bd4bd173eff32a71bfaf8e98ecb6f2f26c0b77f90465d','mobile','2026-09-05 22:16:09','2026-08-06 23:16:09',0,'2026-08-06 20:16:09'),('0bed4098-fb3c-4c91-83ea-d5540fbd963b','c5ece9f2-f9c4-4eba-9865-7879d08bb22b','21541647c0f39c7c230cde56c84b519b1e6c3133005d97ccb2b6d0c097c9b0c1','mobile','2026-09-05 23:54:03','2026-08-07 00:54:04',0,'2026-08-06 21:54:03'),('0ff044af-177a-4f6e-9e4d-04e52d354823','1ff96a34-fef9-4857-9e0b-557f76ce40a9','192f3d34b80f3bd0b81910ba1fd0d081ca54e49aad0d5cadd065a1a89694c375','mobile','2026-09-06 15:31:21','2026-08-07 16:31:38',1,'2026-08-07 13:31:21'),('11ca586a-028a-44fd-afa8-5caaf31ed98f','b96c0a7c-907e-49b2-b539-b1c665bb57f2','d312f9255d8e2c05cd7e53ce32fdfeb9f58a70aca9ebcb3e277c160d9eb617f3','mobile','2026-09-05 23:59:12','2026-08-07 00:59:21',0,'2026-08-06 21:59:12'),('16c199c0-b631-417b-a488-92299baf2383','af582e85-1503-448e-ba2b-272f3a3b6cd4','9ce6602fd82b316cc339f5975ef4df7ed312e7c73129b9ff72c5b4488e583c8c','mobile','2026-09-06 15:27:05','2026-08-07 16:27:21',1,'2026-08-07 13:27:05'),('1b0a4bcf-60a8-4df9-bd95-505169fde8c0','94341787-0a84-4284-9ddd-e16929d851a6','fda90382d3bdf0300d40af8bcca773093f3f09db22cd8f23f868e383d31a2479','mobile','2026-09-05 22:16:07','2026-08-06 23:16:10',1,'2026-08-06 20:16:07'),('1bcda727-de7a-4973-8dfa-1a0a5a4ebc23','4477b345-69ab-48dd-9d99-7126b6bfd8f9','7e2461c5b6e9e133ac21272f5787cf5891b101fee3c1cfda66b2af2606d83619','mobile','2026-09-06 15:26:11','2026-08-07 16:26:15',0,'2026-08-07 13:26:11'),('2b39a5ee-58f3-452f-8465-aed68527d1f4','cd4cca7d-0e48-4be9-b6b6-21b0e21630f4','e18604da067cbc9645749d2227eff1f89676cfa7eb6f79b80a88344befa72d3d','mobile','2026-09-05 22:15:34','2026-08-06 23:15:34',0,'2026-08-06 20:15:34'),('2e2fb7c6-692d-4fe9-9406-0c072f502bf5','6883447f-96e8-4d0f-8ac0-39b0257ed3a0','4355205b6df0a2b5ebb033295a935c6dd92c760fe62c3bb11afc2d5ad265848b','mobile','2026-09-05 22:15:13',NULL,1,'2026-08-06 20:15:13'),('32a06616-a9de-435d-b3cc-5a2a86dcf7f4','373cf8fa-2096-4cfe-a7b8-63942a616927','a6117638d647667e005f54586cf6345112a40c300f53b452f057500e47b0167f','mobile','2026-09-06 00:00:00','2026-08-07 01:00:01',0,'2026-08-06 22:00:00'),('351fbaf2-55fb-4b06-956a-9306851f59cf','1ff96a34-fef9-4857-9e0b-557f76ce40a9','f89080808c56d26b74715df55043e0da5bc6318ed978c9475ed4b930d63bb3ce','mobile','2026-09-06 15:27:59','2026-08-07 16:31:03',1,'2026-08-07 13:27:59'),('36548777-8699-4ef9-8cb7-c0d4164040c4','94341787-0a84-4284-9ddd-e16929d851a6','54cd65195e918fa9341f04cb3249f6577bad015e7a7579726196e06b60808207','mobile','2026-09-05 22:16:06',NULL,1,'2026-08-06 20:16:06'),('3bc179b0-e962-4ad9-9402-ba54f59b7090','41bf4bb6-93f2-47c4-8118-f95681e883b1','94ccc40d436b59965d68f4f287ac0eb0211295a2f2069e90c3b3dece742ee274','mobile','2026-09-05 22:47:33','2026-08-06 23:47:34',0,'2026-08-06 20:47:33'),('3d14e33c-c5bc-4adc-9375-cccac5d4f7b0','8579cbe0-04e6-42c7-bccc-e3662607f94e','13ebaa421f11fcebc4480041814117b453fa6d307118f2dc09ea51147c9a7880','mobile','2026-09-05 22:15:31',NULL,1,'2026-08-06 20:15:31'),('518428dc-ae6d-4384-990a-e1eb246f927f','6883447f-96e8-4d0f-8ac0-39b0257ed3a0','b8b4536789d33c085d3ace4e5c1c0a068c8858a98a32e0c43860122fa5538f4b','mobile','2026-09-05 22:15:17','2026-08-06 23:15:17',0,'2026-08-06 20:15:17'),('5ef8d26a-6318-44ee-979a-6169d195b62f','03f59b81-bce7-470f-bfd6-bd46804315b0','e07bdf81b12f81085aa7588a38d46b565d8e590871c4e92454e0c2096afe0e98','mobile','2026-09-05 22:15:55','2026-08-06 23:15:56',1,'2026-08-06 20:15:55'),('613f7976-7bd8-4d34-afb0-7676db574270','94341787-0a84-4284-9ddd-e16929d851a6','0ebc06fb925c146373572ff4c661c2fd7fc9a6fa24f7f41a7a9a27ef23f483b6','mobile','2026-09-05 22:16:11','2026-08-06 23:16:11',1,'2026-08-06 20:16:11'),('659d8702-28fa-4242-b79f-cf79e3deb483','2dda6721-97c5-439c-a6be-ba846c46315a','3b2ef4cdc9e8b333a97d095e170ed752f50fc9e487e9f76a5f25f1adb92146e4','mobile','2026-09-05 22:13:29','2026-08-06 23:13:29',0,'2026-08-06 20:13:29'),('65a4820d-aa10-428f-8c4c-167344f715ff','2afe7e6c-8b3d-456b-b08d-418887658f3d','3f4ac74812857d06a9a5dfe26a3054a613c225231ba789ebfe72b9b3f4f6f49a','mobile','2026-09-06 15:30:26','2026-08-07 16:30:30',0,'2026-08-07 13:30:26'),('66ba16a7-2ea9-433d-867b-6179609a6342','af582e85-1503-448e-ba2b-272f3a3b6cd4','84f924530ce8fc783eba0ead6536ba70938871c620a78ac207289ce1ca5bb3e3','mobile','2026-09-06 15:23:44','2026-08-07 16:26:48',1,'2026-08-07 13:23:44'),('781dbf64-4d70-4e80-bf72-8cdae8a66098','7510100d-3d34-487b-b6c0-4e8276602ee2','d53004251b8003359eb963f35de99ee008f5e69406834db9f490b5430b528946','mobile','2026-09-05 22:11:51',NULL,0,'2026-08-06 20:11:51'),('78d37e10-dcc4-4eac-8413-101fcb3aaa09','6883447f-96e8-4d0f-8ac0-39b0257ed3a0','cf60674755a09d2e8e78c2467ad9550ef3a4dad0a96b59c98933c86c84c12517','mobile','2026-09-05 22:15:14','2026-08-06 23:15:16',1,'2026-08-06 20:15:14'),('798952b3-e2b4-47fc-88b4-b3a8282f2e70','7510100d-3d34-487b-b6c0-4e8276602ee2','611f6491ce89994353d3c97dd34e79551877067a00b18764967954b0c14e7b45','mobile','2026-09-05 22:11:52','2026-08-06 23:11:55',0,'2026-08-06 20:11:52'),('877eadc9-55ee-49de-b1d4-17f683a77769','373cf8fa-2096-4cfe-a7b8-63942a616927','2ad6810fbf1b6381e0da5b4fcb95cad522c99d3ed2a0bc88e69f353b46d5aa66','mobile','2026-09-05 21:56:14',NULL,0,'2026-08-06 19:56:14'),('929de026-e3bd-43f8-b970-4845dc9d3908','fdff3d5f-7e7e-415d-ad60-cb5c8391d3e5','c544534b386d9f693044b1a4a33f49610359c4bb67677122744767ce160f42fa','mobile','2026-09-05 22:15:58','2026-08-06 23:15:58',0,'2026-08-06 20:15:58'),('931c4f9e-3f20-4d5c-a2c0-847b8dce756f','af582e85-1503-448e-ba2b-272f3a3b6cd4','4d695888b72cf2d5c374a847f6da7f0e131b01e311c23a98a2010e2bc5349dd5','mobile','2026-09-06 15:26:59','2026-08-07 16:27:05',1,'2026-08-07 13:26:59'),('9594c0e6-3815-4712-8527-e1215cc5c579','1ff96a34-fef9-4857-9e0b-557f76ce40a9','4e70488e0d6ae0d4ee39e25103a2147f6120be9e3d0f498a2785e7ad0f9c69dd','mobile','2026-09-06 15:31:14','2026-08-07 16:31:21',1,'2026-08-07 13:31:14'),('96038495-1a30-4207-90ae-0069fd1695c9','f47660b3-8b7a-4b3b-8e11-cf39a93b893c','45f91fc639d3db2b9a76aec6de7184b731d7448429d365bcd7c39801c3ce3fbd','mobile','2026-09-06 15:21:12','2026-08-07 16:21:13',0,'2026-08-07 13:21:12'),('996c8922-85d1-42f1-b221-af6410505ae9','8579cbe0-04e6-42c7-bccc-e3662607f94e','e815fea7453d58a2157269882c1cd4fc8ee8c09367080decc911f44a92fa82c9','mobile','2026-09-05 22:15:32','2026-08-06 23:15:35',1,'2026-08-06 20:15:32'),('9af47097-0cf4-4712-a0b0-4bf19b8d5c9f','3fd23072-881e-4d92-97af-7f19a1588a10','041a944c12b3b9a5caed4a670d2dc75fbcfa3c1d6d2b340f4bf66bc81dfe5e33','mobile','2026-09-05 22:11:54','2026-08-06 23:11:54',0,'2026-08-06 20:11:54'),('9c93b7ed-8d44-45d1-bc02-2012e69f5e31','373cf8fa-2096-4cfe-a7b8-63942a616927','2a0b7dc408ee222e778de5d54fc3e42b79aa49d3a29f281fd3e946fa21f1cdcd','mobile','2026-09-06 15:22:44','2026-08-07 16:22:44',0,'2026-08-07 13:22:44'),('9d1698f6-6dac-48da-ab38-9bc652fd1860','18df8250-d1fd-4cdc-ae2e-7db496c3e6f0','92f0e23c09523296d73915938cbfc3fdb36f10632d4d8d94482ce8dc50e1ffe3','mobile','2026-09-05 22:15:16','2026-08-06 23:15:16',0,'2026-08-06 20:15:16'),('a06249cd-ebab-4f6e-9662-5d9fe22ba12e','6883447f-96e8-4d0f-8ac0-39b0257ed3a0','56c8e0e83a8b53e6e84685ea540a67807ad442b6fcf7cdbee4edd4def644fb1c','mobile','2026-09-05 22:15:13','2026-08-06 23:15:13',1,'2026-08-06 20:15:13'),('a8d9464f-c860-4922-894c-054e258afdb2','03f59b81-bce7-470f-bfd6-bd46804315b0','bf23c8c3f908889741a88dfd7b5d146932610d37b41e62114ffb7bca63d8d29a','mobile','2026-09-05 22:16:00','2026-08-06 23:16:00',1,'2026-08-06 20:16:00'),('b97b3e8d-6a2c-4c57-a625-3d439d0b8066','1ff96a34-fef9-4857-9e0b-557f76ce40a9','d11f32b54cf7fe7991d11f1c5736404231c0c0fae41fd5122679a8d1c7d52c2c','mobile','2026-09-06 15:27:37','2026-08-07 16:27:55',1,'2026-08-07 13:27:37'),('c13aafcd-6fe2-447a-a96d-f7ec29fc081e','8579cbe0-04e6-42c7-bccc-e3662607f94e','8a0e66341b738eb2d67731bd2d65b78380f517293c76be86b67ca53dfc6fdba6','mobile','2026-09-05 22:15:35','2026-08-06 23:15:36',1,'2026-08-06 20:15:35'),('c32aa36e-9b0c-475f-a988-4d329b4deb5b','6883447f-96e8-4d0f-8ac0-39b0257ed3a0','f4e1331c7864b44fdf9efe0a1445557aa70c324ad86cdb371f8baa5d98cad616','mobile','2026-09-05 22:15:17','2026-08-06 23:15:17',1,'2026-08-06 20:15:17'),('c7bcd10a-7e50-43ab-b1b8-88c8f6dff92f','2dd5aee9-7f08-4a87-a7a2-72a4a20b5f97','d9b53847efbfb0608e304e56f607015018649417b76bb7ce14054ef70e3fe5c6','mobile','2026-09-06 15:22:37','2026-08-07 16:22:39',0,'2026-08-07 13:22:37'),('cab57f18-73ee-46b9-9ae1-20907563a041','03f59b81-bce7-470f-bfd6-bd46804315b0','19f3f2bd84648966ab0165e1d2454d5ccdfb3ea9a0576d0e671fac0537092cd8','mobile','2026-09-05 22:15:59','2026-08-06 23:16:00',1,'2026-08-06 20:15:59'),('cb80af35-3246-4e05-8979-f868b7a1cb6c','03f59b81-bce7-470f-bfd6-bd46804315b0','dcfe5502e5bfff0f7d9b477f992ee06ee5c8d0ef4414e19c27adeb089beb750e','mobile','2026-09-05 22:15:55',NULL,1,'2026-08-06 20:15:55'),('d11f2ba0-e07c-465f-bce9-d39cadbf9e99','373cf8fa-2096-4cfe-a7b8-63942a616927','7f338c4c89f81a4534be56ab15b408f5e0a3ec9c3bfbbeeffd50e883f87d5f32','mobile','2026-09-05 22:45:21','2026-08-06 23:45:22',0,'2026-08-06 20:45:21'),('d2b02b30-e6a3-44d5-9a35-c405ac4303c9','2dd5aee9-7f08-4a87-a7a2-72a4a20b5f97','d0de8c5a40ad4a6d60e65fff2f9443604230a47685dff9740bab3246b5e463a9','mobile','2026-09-06 15:22:24','2026-08-07 16:22:32',1,'2026-08-07 13:22:24'),('d69faf35-e5db-4bee-addc-28338964f76c','f47660b3-8b7a-4b3b-8e11-cf39a93b893c','8b092cc39763fbbac3fed2787ad22642ca8965e42fa2ed208e88c5aede8af765','mobile','2026-09-06 15:20:58','2026-08-07 16:21:07',1,'2026-08-07 13:20:58'),('dc282065-2587-408e-bab4-ad9cac707141','8579cbe0-04e6-42c7-bccc-e3662607f94e','9fba502f344469a77cd94a17e77bd86c20fb4b8ac78b56e0bb6cb8d63e21490f','mobile','2026-09-05 22:15:31','2026-08-06 23:15:32',1,'2026-08-06 20:15:31'),('e7bf42cd-7e49-48b9-a1f4-88e49627f2bd','03f59b81-bce7-470f-bfd6-bd46804315b0','8df53c4e39ce38e3836b050b0056a74b6e01e174395c21ec2402804623ddcf83','mobile','2026-09-05 22:15:56','2026-08-06 23:15:59',1,'2026-08-06 20:15:56'),('eb7fe7ec-1a3c-4d15-828f-97a6e20f49b2','94341787-0a84-4284-9ddd-e16929d851a6','4ca5268e30121d1d1ef8c2525fa6dc78c8716289793ce4c71c3f4286e2f1cad2','mobile','2026-09-05 22:16:10','2026-08-06 23:16:11',1,'2026-08-06 20:16:10'),('efd2597b-3d12-4154-8681-87afd5433a66','94341787-0a84-4284-9ddd-e16929d851a6','e62d619f26185ad859043c255d7e631809cdda2952e057c6566917caf8fb665d','mobile','2026-09-05 22:16:06','2026-08-06 23:16:06',1,'2026-08-06 20:16:06'),('f53ea145-9dce-4682-872b-2f1c77a065e7','7510100d-3d34-487b-b6c0-4e8276602ee2','e2f4f19a83690623be4d5272daa39963e535255354bc1408a25cd0043e9c0c40','mobile','2026-09-05 22:11:51','2026-08-06 23:11:52',1,'2026-08-06 20:11:51'),('f9572e06-9192-413a-98a9-64e4d22153f3','1ff96a34-fef9-4857-9e0b-557f76ce40a9','a09b90640fd2a8bc071c5ec007f8022b3c0229bf17128d1508f70b2b707e8b9c','mobile','2026-09-06 15:27:43',NULL,1,'2026-08-07 13:27:43'),('fc4345fe-65aa-4956-9ba6-d249ad338928','8579cbe0-04e6-42c7-bccc-e3662607f94e','e1442f3f9b0520bf25b5771291d63ff58291fdefb6b4a2a19351da5926e85d16','mobile','2026-09-05 22:15:36','2026-08-06 23:15:36',1,'2026-08-06 20:15:36'),('fe108139-d99d-4aad-834e-09455c4feb49','af582e85-1503-448e-ba2b-272f3a3b6cd4','3eacf7a2982ceec761c44f342c6d417a3fae7b4ef135530f0c29d94ebb4f7e79','mobile','2026-09-06 15:23:27',NULL,1,'2026-08-07 13:23:27');
/*!40000 ALTER TABLE `auth_tokens` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `children`
--

DROP TABLE IF EXISTS `children`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `children` (
  `id` char(36) NOT NULL,
  `parent_id` char(36) NOT NULL,
  `name` varchar(120) NOT NULL,
  `age` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `grade` varchar(60) NOT NULL DEFAULT '',
  `school` varchar(160) NOT NULL DEFAULT '',
  `avatar_key` varchar(32) NOT NULL DEFAULT 'sunshine',
  `pin` varchar(4) NOT NULL DEFAULT '',
  `coins` int(10) unsigned NOT NULL DEFAULT 0,
  `streak_days` int(10) unsigned NOT NULL DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_children_parent` (`parent_id`),
  CONSTRAINT `fk_children_parent` FOREIGN KEY (`parent_id`) REFERENCES `parents` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `children`
--

LOCK TABLES `children` WRITE;
/*!40000 ALTER TABLE `children` DISABLE KEYS */;
INSERT INTO `children` VALUES ('1a0f8091-17e6-4045-92c0-54a6de126c27','3fd23072-881e-4d92-97af-7f19a1588a10','Other Kid',6,'','','sunshine','',0,0,'2026-08-06 20:11:54','2026-08-06 20:11:54'),('256ad462-d191-49e2-b671-606fbec688da','373cf8fa-2096-4cfe-a7b8-63942a616927','Mia',7,'Grade 2','Sunshine Elementary','sunshine','',240,5,'2026-08-06 16:51:16','2026-08-06 18:21:16'),('2a3ef0f7-7a72-4bda-b093-3d34f0dc254c','2afe7e6c-8b3d-456b-b08d-418887658f3d','Other Kid',6,'','','sunshine','',0,0,'2026-08-07 13:30:30','2026-08-07 13:30:30'),('389dca8a-1d50-4cbe-8ba6-bee37b46b8ea','b96c0a7c-907e-49b2-b539-b1c665bb57f2','Mia',7,'Pre-school','','sunshine','',0,0,'2026-08-06 21:59:21','2026-08-06 21:59:21'),('4b889e93-d3fd-437b-8af6-85f8dd0f024d','6883447f-96e8-4d0f-8ac0-39b0257ed3a0','Test Kid 2',9,'Grade 3','QA Elementary','sunshine','1234',25,0,'2026-08-06 20:15:14','2026-08-06 20:15:15'),('6d89c02e-6f51-426f-bb25-06161c367e76','7510100d-3d34-487b-b6c0-4e8276602ee2','Test Kid 2',9,'Grade 3','QA Elementary','sunshine','1234',25,0,'2026-08-06 20:11:52','2026-08-06 20:11:53'),('75f0fa91-7034-4ca1-9e93-d2886e01dbdc','373cf8fa-2096-4cfe-a7b8-63942a616927','Ava',9,'Grade 4','Sunshine Elementary','mint','',95,1,'2026-08-06 16:53:16','2026-08-06 18:21:16'),('7bdbe71e-9173-4700-9889-d59a564e9910','18df8250-d1fd-4cdc-ae2e-7db496c3e6f0','Other Kid',6,'','','sunshine','',0,0,'2026-08-06 20:15:16','2026-08-06 20:15:16'),('7d99ca09-66c5-44d8-8cd2-691f5f507aaa','2db5d16d-bca8-460b-a87d-df7c47f9bbe4','Other Kid',6,'','','sunshine','',0,0,'2026-08-06 20:16:09','2026-08-06 20:16:09'),('88c1fb83-01ef-47db-af95-87f0ec09b873','2dd5aee9-7f08-4a87-a7a2-72a4a20b5f97','Mia',7,'Pre-school','','sunshine','',0,0,'2026-08-07 13:22:31','2026-08-07 13:22:31'),('9bfdc399-94a0-454d-8e8e-01076e887e9c','fdff3d5f-7e7e-415d-ad60-cb5c8391d3e5','Other Kid',6,'','','sunshine','',0,0,'2026-08-06 20:15:58','2026-08-06 20:15:58'),('b18874c0-237f-4912-b606-d0ccbd01402c','373cf8fa-2096-4cfe-a7b8-63942a616927','Leo',5,'Kindergarten','Sunshine Elementary','sky','',180,3,'2026-08-06 16:52:16','2026-08-06 18:21:16'),('d074fbe6-9794-4e20-9cf7-180537535440','cd4cca7d-0e48-4be9-b6b6-21b0e21630f4','Other Kid',6,'','','sunshine','',0,0,'2026-08-06 20:15:34','2026-08-06 20:15:34'),('f11f6762-ba1c-4d7a-8135-3f6e971359a3','4477b345-69ab-48dd-9d99-7126b6bfd8f9','Other Kid',6,'','','sunshine','',0,0,'2026-08-07 13:26:15','2026-08-07 13:26:15'),('f588234e-95e5-4a11-a142-2441ec037251','f47660b3-8b7a-4b3b-8e11-cf39a93b893c','Mia',7,'Pre-school','','sunshine','',0,0,'2026-08-07 13:21:06','2026-08-07 13:21:06');
/*!40000 ALTER TABLE `children` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `homework`
--

DROP TABLE IF EXISTS `homework`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `homework` (
  `id` char(36) NOT NULL,
  `child_id` char(36) NOT NULL,
  `title` varchar(160) NOT NULL,
  `subject` varchar(80) NOT NULL,
  `icon` varchar(40) NOT NULL DEFAULT 'book',
  `due_date` date NOT NULL,
  `status` enum('pending','inProgress','completed') NOT NULL DEFAULT 'pending',
  `coins` int(10) unsigned NOT NULL DEFAULT 5,
  `progress` decimal(4,2) NOT NULL DEFAULT 0.00,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_homework_child_due` (`child_id`,`due_date`),
  CONSTRAINT `fk_homework_child` FOREIGN KEY (`child_id`) REFERENCES `children` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `homework`
--

LOCK TABLES `homework` WRITE;
/*!40000 ALTER TABLE `homework` DISABLE KEYS */;
INSERT INTO `homework` VALUES ('40754335-e1aa-4c3f-9ae6-cee1c490d8ae','256ad462-d191-49e2-b671-606fbec688da','Math worksheet - page 12','Math','book','2026-08-06','completed',10,1.00,'2026-08-06 18:21:16','2026-08-06 18:21:16'),('7c28f6a8-d379-4766-8743-56a794c1fd99','256ad462-d191-49e2-b671-606fbec688da','Spelling practice','English','edit','2026-08-06','completed',5,1.00,'2026-08-06 18:21:16','2026-08-06 18:21:16'),('a2c3c670-995b-4c81-a484-f6fa703bcda2','256ad462-d191-49e2-b671-606fbec688da','Read 20 minutes','English','book','2026-08-06','completed',10,1.00,'2026-08-06 18:21:16','2026-08-06 18:21:16'),('cecce818-08ea-4479-8d4c-4795a4eb9854','256ad462-d191-49e2-b671-606fbec688da','Science: collect leaves','Science','plants','2026-08-08','pending',10,0.00,'2026-08-06 18:21:16','2026-08-06 18:21:16'),('dff6cf58-7272-49f2-8dee-8e98bf2d0604','256ad462-d191-49e2-b671-606fbec688da','Draw your family','Art','paint','2026-08-07','inProgress',5,0.50,'2026-08-06 18:21:16','2026-08-06 18:21:16');
/*!40000 ALTER TABLE `homework` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `meals`
--

DROP TABLE IF EXISTS `meals`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `meals` (
  `id` char(36) NOT NULL,
  `child_id` char(36) NOT NULL,
  `date` date NOT NULL,
  `type` enum('breakfast','lunch','dinner','snack') NOT NULL,
  `name` varchar(160) NOT NULL,
  `icon` varchar(40) NOT NULL DEFAULT '',
  `time` varchar(16) NOT NULL DEFAULT '',
  `calories` smallint(5) unsigned NOT NULL DEFAULT 0,
  `protein` smallint(5) unsigned NOT NULL DEFAULT 0,
  `carbs` smallint(5) unsigned NOT NULL DEFAULT 0,
  `fat` smallint(5) unsigned NOT NULL DEFAULT 0,
  `eaten` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_meals_child_date` (`child_id`,`date`),
  CONSTRAINT `fk_meals_child` FOREIGN KEY (`child_id`) REFERENCES `children` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `meals`
--

LOCK TABLES `meals` WRITE;
/*!40000 ALTER TABLE `meals` DISABLE KEYS */;
INSERT INTO `meals` VALUES ('08ec14b0-0518-487b-8761-1c85bb7fa630','256ad462-d191-49e2-b671-606fbec688da','2026-08-06','snack','Apple slices','heart','10:30 AM',80,0,20,0,1,'2026-08-06 18:21:16'),('1cea5a02-b7d4-4c5d-8c4d-93f08edef715','256ad462-d191-49e2-b671-606fbec688da','2026-08-06','dinner','Spaghetti with meatballs','moon','6:30 PM',520,24,62,16,0,'2026-08-06 18:21:16'),('89997a24-73eb-421c-a855-96b05240f39d','256ad462-d191-49e2-b671-606fbec688da','2026-08-06','breakfast','Oatmeal with berries','sun','7:45 AM',260,9,42,4,1,'2026-08-06 18:21:16'),('e90ffce0-c843-45a3-87c6-13d2c8f18ccd','256ad462-d191-49e2-b671-606fbec688da','2026-08-06','lunch','Chicken sandwich & salad','food','12:30 PM',410,28,34,14,1,'2026-08-06 18:21:16');
/*!40000 ALTER TABLE `meals` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `moods`
--

DROP TABLE IF EXISTS `moods`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `moods` (
  `id` char(36) NOT NULL,
  `child_id` char(36) NOT NULL,
  `date` datetime NOT NULL,
  `mood` enum('happy','excited','calm','tired','sad','angry') NOT NULL,
  `note` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_moods_child_date` (`child_id`,`date`),
  CONSTRAINT `fk_moods_child` FOREIGN KEY (`child_id`) REFERENCES `children` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `moods`
--

LOCK TABLES `moods` WRITE;
/*!40000 ALTER TABLE `moods` DISABLE KEYS */;
INSERT INTO `moods` VALUES ('02918935-1440-40d4-ac8d-4b5631da379a','256ad462-d191-49e2-b671-606fbec688da','2026-08-02 20:21:16','sad','Lost my favourite sticker.','2026-08-06 18:21:16'),('26e0ff31-c169-424b-96dd-44865b0dd744','256ad462-d191-49e2-b671-606fbec688da','2026-08-05 20:21:16','calm','Quiet afternoon with books.','2026-08-06 18:21:16'),('99f97c2f-99c6-4434-97d2-91a119ed17d5','256ad462-d191-49e2-b671-606fbec688da','2026-08-03 20:21:16','tired','Long day at school.','2026-08-06 18:21:16'),('9b0990a0-5433-4900-8f15-3cad54dce4d8','256ad462-d191-49e2-b671-606fbec688da','2026-08-06 20:21:16','happy','Loved the drawing class today!','2026-08-06 18:21:16'),('9b4b35d8-b155-4947-b7b1-8d8cd00803df','256ad462-d191-49e2-b671-606fbec688da','2026-08-04 20:21:16','excited','Play date with Ava!','2026-08-06 18:21:16');
/*!40000 ALTER TABLE `moods` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `notifications`
--

DROP TABLE IF EXISTS `notifications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `notifications` (
  `id` char(36) NOT NULL,
  `parent_id` char(36) NOT NULL,
  `child_id` char(36) DEFAULT NULL,
  `type` enum('activity','meal','homework','announcement') NOT NULL DEFAULT 'activity',
  `title` varchar(160) NOT NULL,
  `message` text NOT NULL,
  `icon` varchar(40) NOT NULL DEFAULT 'bell',
  `is_read` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_notifications_parent` (`parent_id`),
  KEY `idx_notifications_read` (`parent_id`,`is_read`),
  KEY `fk_notifications_child` (`child_id`),
  KEY `idx_notifications_parent_created` (`parent_id`,`created_at`),
  CONSTRAINT `fk_notifications_child` FOREIGN KEY (`child_id`) REFERENCES `children` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_notifications_parent` FOREIGN KEY (`parent_id`) REFERENCES `parents` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notifications`
--

LOCK TABLES `notifications` WRITE;
/*!40000 ALTER TABLE `notifications` DISABLE KEYS */;
INSERT INTO `notifications` VALUES ('1e7948e4-b78e-4235-b0f6-5cd7559c3a85','373cf8fa-2096-4cfe-a7b8-63942a616927','256ad462-d191-49e2-b671-606fbec688da','activity','Evening routine','Bedtime is in 30 minutes. Start the evening wind-down.','moon',0,'2026-08-06 14:51:16'),('2afab84b-69a8-45fd-a851-7a07433753e1','373cf8fa-2096-4cfe-a7b8-63942a616927','256ad462-d191-49e2-b671-606fbec688da','meal','Dinner time','It is dinner time. Mia still needs to eat her spaghetti.','food',0,'2026-08-06 16:06:16'),('2be0336c-0418-4927-b6f6-5b66365884eb','373cf8fa-2096-4cfe-a7b8-63942a616927','256ad462-d191-49e2-b671-606fbec688da','meal','Hydration goal','Mia reached 6 of 8 glasses today. Keep it going!','water',1,'2026-08-05 11:21:16'),('601106a1-a6a8-483f-b13c-6c0e7a221298','373cf8fa-2096-4cfe-a7b8-63942a616927','256ad462-d191-49e2-b671-606fbec688da','announcement','Parent announcement','Parent-teacher meeting on Friday at 4 PM. Please confirm attendance.','bell',1,'2026-08-06 11:21:16'),('8167a978-094e-4fb6-9c70-14c1db04afab','373cf8fa-2096-4cfe-a7b8-63942a616927','256ad462-d191-49e2-b671-606fbec688da','homework','Homework reminder','Mia has 2 homework tasks due today. Help her finish them!','homework',0,'2026-08-06 16:51:16'),('92119ad0-8b9b-4a0f-bd9a-2546b78aabe3','2dda6721-97c5-439c-a6be-ba846c46315a',NULL,'activity','hi','msg','bell',1,'2026-08-06 20:13:29'),('d20652a2-d7ff-4f01-89fe-2445e059e9f0','373cf8fa-2096-4cfe-a7b8-63942a616927','256ad462-d191-49e2-b671-606fbec688da','activity','Screen time alert','Mia used 65 minutes of screen time yesterday, 5 over the limit.','target',1,'2026-08-05 17:21:16');
/*!40000 ALTER TABLE `notifications` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `parents`
--

DROP TABLE IF EXISTS `parents`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `parents` (
  `id` char(36) NOT NULL,
  `full_name` varchar(120) NOT NULL,
  `email` varchar(190) NOT NULL,
  `phone` varchar(32) NOT NULL DEFAULT '',
  `password_hash` varchar(255) NOT NULL,
  `avatar_key` varchar(32) NOT NULL DEFAULT 'grape',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_parents_email` (`email`),
  KEY `idx_parents_email` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `parents`
--

LOCK TABLES `parents` WRITE;
/*!40000 ALTER TABLE `parents` DISABLE KEYS */;
INSERT INTO `parents` VALUES ('03f59b81-bce7-470f-bfd6-bd46804315b0','QA Tester Updated','qa+63f5c5ff5d@example.com','+1 555 999 888','$2y$10$DB9uwlByh7AfwFiJ4Anqd.jjrAwc1P9jFfapTPK3IsHKanuqMVvza','grape','2026-08-06 20:15:55','2026-08-06 20:16:00'),('18df8250-d1fd-4cdc-ae2e-7db496c3e6f0','Other Parent','other+e8647212c8@example.com','','$2y$10$Tp24EwwTtEAOgm2PWGAxTOoMH/coPv6vRcC/qc2A.5QeB3e0T3Bxi','grape','2026-08-06 20:15:16','2026-08-06 20:15:16'),('1ff96a34-fef9-4857-9e0b-557f76ce40a9','QA Tester Updated','qa+b336127547@example.com','+1 555 999 888','$2y$10$w8T71H/jWYOhqR42FWJAQeK2w7IJJKDDR2ejIc64gXlq5QpLINPDi','grape','2026-08-07 13:27:37','2026-08-07 13:31:21'),('2afe7e6c-8b3d-456b-b08d-418887658f3d','Other Parent','other+6342746f63@example.com','','$2y$10$Y.oiipPebIxjQmKakqUp5.KBt/LtLbmHA6BedZQYHqX2h/R1eWziK','grape','2026-08-07 13:30:26','2026-08-07 13:30:26'),('2db5d16d-bca8-460b-a87d-df7c47f9bbe4','Other Parent','other+6bc9c07c33@example.com','','$2y$10$V/Z/b2.Ky0vKRjpD7BoGCuQqBYF2CLQHrPFgATW8d9Qzn0HBXcNN2','grape','2026-08-06 20:16:09','2026-08-06 20:16:09'),('2dd5aee9-7f08-4a87-a7a2-72a4a20b5f97','QA Flow Tester','uitest+1786058397033@example.com','+1 555 010 999','$2y$10$dQebBkEcLwzCX93s4pNjEeLIHDj5/rTbSdHkjOlaE/mp90CfDCINC','grape','2026-08-07 13:22:24','2026-08-07 13:22:24'),('2dda6721-97c5-439c-a6be-ba846c46315a','QA Repro','repro+f8475dd6@example.com','','$2y$10$qLXpZm7s8bmg80SLUFIc2.z.I9ViJxYcgSVKkyFrWg.dB6HkUhk0G','grape','2026-08-06 20:13:29','2026-08-06 20:13:29'),('373cf8fa-2096-4cfe-a7b8-63942a616927','Dana Smith','dana@example.com','+1 555 010 2030','$2y$10$jDidx2jfXxkaNUhC9v8sL.Ukuq78khTs2IPGbOpUYnnM3DTa6StOm','grape','2026-08-06 18:21:16','2026-08-06 18:21:16'),('3fd23072-881e-4d92-97af-7f19a1588a10','Other Parent','other+6e2ee6ef94@example.com','','$2y$10$.a0jMXeWmvnLwEcgLG92J./z4IIQ3DfF29bSSC3bb3TRjwSR4khG6','grape','2026-08-06 20:11:54','2026-08-06 20:11:54'),('41bf4bb6-93f2-47c4-8118-f95681e883b1','QA Flow Tester','uitest+1786049250622@example.com','+1 555 010 999','$2y$10$0Hq/2nAduEoNfdmHF5K43erlnxhE5.3HktQbI3wJhRTWAqEdkijiu','grape','2026-08-06 20:47:33','2026-08-06 20:47:33'),('4477b345-69ab-48dd-9d99-7126b6bfd8f9','Other Parent','other+6a16ee4d8d@example.com','','$2y$10$zHYV.D0DDj4orhX5Sb6BI.jMKHovKUhqF38i2NECAMhyNe01MSkI6','grape','2026-08-07 13:26:11','2026-08-07 13:26:11'),('6883447f-96e8-4d0f-8ac0-39b0257ed3a0','QA Tester Updated','qa+0e26d4bab8@example.com','+1 555 999 888','$2y$10$bkUQLjLkIIsrua2NgYE4suld4JsRHb9bPrHECF8AzqyrXJ2JZCbNq','grape','2026-08-06 20:15:13','2026-08-06 20:15:17'),('7510100d-3d34-487b-b6c0-4e8276602ee2','QA Tester Updated','qa+63f2ca5816@example.com','+1 555 999 888','$2y$10$ovRqh.E1xqoZhJd9ZuZ7..t.h6W/E/FJSec4XkIhN22iWresdi/qO','grape','2026-08-06 20:11:51','2026-08-06 20:11:52'),('8579cbe0-04e6-42c7-bccc-e3662607f94e','QA Tester Updated','qa+5ea39c6bb3@example.com','+1 555 999 888','$2y$10$OmZh897ErUAjXf04XKcN../mGFrZjBFsHAdyxAd7ESawscAyIyAmm','grape','2026-08-06 20:15:31','2026-08-06 20:15:36'),('94341787-0a84-4284-9ddd-e16929d851a6','QA Tester Updated','qa+d3fb48cde9@example.com','+1 555 999 888','$2y$10$x9SQNxli2670Oi5xiYM2zeLU.OoDIDOwux7pnrFzpZofE8MOM1LsC','grape','2026-08-06 20:16:06','2026-08-06 20:16:11'),('af582e85-1503-448e-ba2b-272f3a3b6cd4','QA Tester Updated','qa+171f211a97@example.com','+1 555 999 888','$2y$10$/Xa7mhurEp0sTHQv5n2yy.gCXp7.JklOkruCLef23yJGReo/TPB1S','grape','2026-08-07 13:23:21','2026-08-07 13:27:05'),('b96c0a7c-907e-49b2-b539-b1c665bb57f2','QA Flow Tester','uitest+1786050120342@example.com','+1 555 010 999','$2y$10$D1mxcu2I0kLLvmHUvYT2K.vXghuI.jU2lalsys/haLlOkSp.rtxWC','grape','2026-08-06 21:59:12','2026-08-06 21:59:12'),('c5ece9f2-f9c4-4eba-9865-7879d08bb22b','QA Flow Tester','uitest+1786049810843@example.com','+1 555 010 999','$2y$10$nNX28hcgKyRnVgeGy2sGRehvr1WQB9tPipTMgV52f15QW5yogSWLa','grape','2026-08-06 21:54:03','2026-08-06 21:54:03'),('cd4cca7d-0e48-4be9-b6b6-21b0e21630f4','Other Parent','other+c233fd9660@example.com','','$2y$10$qKl4mISixpjTk.YBMQvtvOTFqZOCEts6L5dV1Gia5gE/lBVSU7Ct2','grape','2026-08-06 20:15:34','2026-08-06 20:15:34'),('f47660b3-8b7a-4b3b-8e11-cf39a93b893c','QA Flow Tester','uitest+1786058311662@example.com','+1 555 010 999','$2y$10$rzYBLTtGocYBvcA64ny2S.dpNSEom2feImebTvULBO0CnJw3uBAH2','grape','2026-08-07 13:20:58','2026-08-07 13:20:58'),('fdff3d5f-7e7e-415d-ad60-cb5c8391d3e5','Other Parent','other+37f1e75f5b@example.com','','$2y$10$2zX9SDEAsG9ZpaEpC.Bwt.cV/GQWY49NsExXqcnVBy5RmajMGyueq','grape','2026-08-06 20:15:58','2026-08-06 20:15:58');
/*!40000 ALTER TABLE `parents` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `password_resets`
--

DROP TABLE IF EXISTS `password_resets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `password_resets` (
  `id` char(36) NOT NULL,
  `parent_id` char(36) NOT NULL,
  `token_hash` char(64) NOT NULL,
  `expires_at` datetime NOT NULL,
  `used` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_password_resets_hash` (`token_hash`),
  KEY `idx_password_resets_parent` (`parent_id`),
  CONSTRAINT `fk_password_resets_parent` FOREIGN KEY (`parent_id`) REFERENCES `parents` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `password_resets`
--

LOCK TABLES `password_resets` WRITE;
/*!40000 ALTER TABLE `password_resets` DISABLE KEYS */;
INSERT INTO `password_resets` VALUES ('423b09f3-792e-4bd9-b6e3-11ea8b313b8a','1ff96a34-fef9-4857-9e0b-557f76ce40a9','9a7f509cf5e2ac3030f1037ad1dc2932cc4b080290d93679d73ce9dc49dcc95e','2026-08-07 16:31:05',1,'2026-08-07 13:31:05'),('482be0c9-69ef-4ea0-b916-82043e2f4742','8579cbe0-04e6-42c7-bccc-e3662607f94e','a592c24c0e472e9d66c5b4e550efe73ff1adeef27127dece8e17775bef7e7567','2026-08-06 23:15:35',1,'2026-08-06 20:15:35'),('6cd975b0-a353-4a6c-ab64-6d4c5ca11089','6883447f-96e8-4d0f-8ac0-39b0257ed3a0','32f91958371bf19ca7cd66bd8de62c2d90785f0fa60d3a05f67ebede18d32fc9','2026-08-06 23:15:16',1,'2026-08-06 20:15:16'),('c647d070-4f72-4738-9b11-c4ebff8ed11f','af582e85-1503-448e-ba2b-272f3a3b6cd4','0073876b4c71e1246f53a2872b72f20b44d74a558ab6962bb957ef257516a8cb','2026-08-07 16:26:50',1,'2026-08-07 13:26:50'),('c72ecaf4-1a07-48f6-b72a-2833eabc150c','94341787-0a84-4284-9ddd-e16929d851a6','4e24328b22629a82945ec2264095756553826d0c93f1f3baa7d8189671637ba2','2026-08-06 23:16:10',1,'2026-08-06 20:16:10'),('dcdd0c93-aa1a-4609-9f69-22d312891cfa','03f59b81-bce7-470f-bfd6-bd46804315b0','54d4f92fb53ecef8b4ba5a54d79930c4715d99600c6ce353da0bf5aab1fae71b','2026-08-06 23:15:59',1,'2026-08-06 20:15:59');
/*!40000 ALTER TABLE `password_resets` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `reports`
--

DROP TABLE IF EXISTS `reports`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `reports` (
  `id` char(36) NOT NULL,
  `child_id` char(36) NOT NULL,
  `type` enum('daily','weekly','monthly') NOT NULL,
  `period_date` date NOT NULL,
  `data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL CHECK (json_valid(`data`)),
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_reports_child_type_period` (`child_id`,`type`,`period_date`),
  CONSTRAINT `fk_reports_child` FOREIGN KEY (`child_id`) REFERENCES `children` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `reports`
--

LOCK TABLES `reports` WRITE;
/*!40000 ALTER TABLE `reports` DISABLE KEYS */;
INSERT INTO `reports` VALUES ('0835e77c-3355-437c-88a2-6f8a51baecd4','256ad462-d191-49e2-b671-606fbec688da','weekly','2026-08-03','{\"tasksDone\":6,\"completionRate\":50,\"coins\":40,\"dayStreak\":5,\"sleepHours\":9,\"waterGlasses\":6,\"taskChart\":[{\"label\":\"Mon\",\"value\":0},{\"label\":\"Tue\",\"value\":0},{\"label\":\"Wed\",\"value\":0},{\"label\":\"Thu\",\"value\":3},{\"label\":\"Fri\",\"value\":0},{\"label\":\"Sat\",\"value\":0},{\"label\":\"Sun\",\"value\":0}],\"trendChart\":[{\"label\":\"Mon\",\"value\":8.5},{\"label\":\"Tue\",\"value\":9},{\"label\":\"Wed\",\"value\":9},{\"label\":\"Thu\",\"value\":9.5},{\"label\":\"Fri\",\"value\":0},{\"label\":\"Sat\",\"value\":0},{\"label\":\"Sun\",\"value\":0}],\"categoryChart\":[{\"label\":\"Morning routine\",\"value\":3}],\"attendance\":[{\"label\":\"present\",\"value\":4},{\"label\":\"absent\",\"value\":0},{\"label\":\"late\",\"value\":0}]}','2026-08-07 13:22:44'),('0ad757f9-7f64-42d9-8776-b21f8137c8b5','f588234e-95e5-4a11-a142-2441ec037251','weekly','2026-08-03','{\"tasksDone\":0,\"completionRate\":0,\"coins\":0,\"dayStreak\":0,\"sleepHours\":0,\"waterGlasses\":0,\"taskChart\":[{\"label\":\"Mon\",\"value\":0},{\"label\":\"Tue\",\"value\":0},{\"label\":\"Wed\",\"value\":0},{\"label\":\"Thu\",\"value\":0},{\"label\":\"Fri\",\"value\":0},{\"label\":\"Sat\",\"value\":0},{\"label\":\"Sun\",\"value\":0}],\"trendChart\":[{\"label\":\"Mon\",\"value\":0},{\"label\":\"Tue\",\"value\":0},{\"label\":\"Wed\",\"value\":0},{\"label\":\"Thu\",\"value\":0},{\"label\":\"Fri\",\"value\":0},{\"label\":\"Sat\",\"value\":0},{\"label\":\"Sun\",\"value\":0}],\"categoryChart\":[],\"attendance\":[{\"label\":\"present\",\"value\":0},{\"label\":\"absent\",\"value\":0},{\"label\":\"late\",\"value\":0}]}','2026-08-07 13:21:13'),('28fbec1c-351c-4e5c-8c33-759935e20b3f','6d89c02e-6f51-426f-bb25-06161c367e76','daily','2026-08-06','{\"tasksDone\":1,\"completionRate\":100,\"coins\":10,\"dayStreak\":0,\"sleepHours\":0,\"waterGlasses\":0,\"taskChart\":[{\"label\":\"1\",\"value\":0},{\"label\":\"2\",\"value\":0},{\"label\":\"3\",\"value\":0},{\"label\":\"4\",\"value\":0},{\"label\":\"5\",\"value\":0},{\"label\":\"6\",\"value\":1}],\"trendChart\":[{\"label\":\"Fri\",\"value\":0},{\"label\":\"Sat\",\"value\":0},{\"label\":\"Sun\",\"value\":0},{\"label\":\"Mon\",\"value\":0},{\"label\":\"Tue\",\"value\":0},{\"label\":\"Wed\",\"value\":0},{\"label\":\"Thu\",\"value\":0}],\"categoryChart\":[{\"label\":\"Routine\",\"value\":1}],\"attendance\":[{\"label\":\"present\",\"value\":0},{\"label\":\"absent\",\"value\":0},{\"label\":\"late\",\"value\":0}]}','2026-08-06 20:11:54'),('2ca43f23-71d8-4ff6-90f4-775529b33091','4b889e93-d3fd-437b-8af6-85f8dd0f024d','daily','2026-08-06','{\"tasksDone\":1,\"completionRate\":100,\"coins\":10,\"dayStreak\":0,\"sleepHours\":0,\"waterGlasses\":0,\"taskChart\":[{\"label\":\"1\",\"value\":0},{\"label\":\"2\",\"value\":0},{\"label\":\"3\",\"value\":0},{\"label\":\"4\",\"value\":0},{\"label\":\"5\",\"value\":0},{\"label\":\"6\",\"value\":1}],\"trendChart\":[{\"label\":\"Fri\",\"value\":0},{\"label\":\"Sat\",\"value\":0},{\"label\":\"Sun\",\"value\":0},{\"label\":\"Mon\",\"value\":0},{\"label\":\"Tue\",\"value\":0},{\"label\":\"Wed\",\"value\":0},{\"label\":\"Thu\",\"value\":0}],\"categoryChart\":[{\"label\":\"Routine\",\"value\":1}],\"attendance\":[{\"label\":\"present\",\"value\":0},{\"label\":\"absent\",\"value\":0},{\"label\":\"late\",\"value\":0}]}','2026-08-06 20:15:16'),('47a91564-cd3f-4b26-9453-895a80bfbb27','6d89c02e-6f51-426f-bb25-06161c367e76','weekly','2026-08-03','{\"tasksDone\":1,\"completionRate\":100,\"coins\":10,\"dayStreak\":0,\"sleepHours\":0,\"waterGlasses\":0,\"taskChart\":[{\"label\":\"Mon\",\"value\":0},{\"label\":\"Tue\",\"value\":0},{\"label\":\"Wed\",\"value\":0},{\"label\":\"Thu\",\"value\":1},{\"label\":\"Fri\",\"value\":0},{\"label\":\"Sat\",\"value\":0},{\"label\":\"Sun\",\"value\":0}],\"trendChart\":[{\"label\":\"Mon\",\"value\":0},{\"label\":\"Tue\",\"value\":0},{\"label\":\"Wed\",\"value\":0},{\"label\":\"Thu\",\"value\":0},{\"label\":\"Fri\",\"value\":0},{\"label\":\"Sat\",\"value\":0},{\"label\":\"Sun\",\"value\":0}],\"categoryChart\":[{\"label\":\"Routine\",\"value\":1}],\"attendance\":[{\"label\":\"present\",\"value\":0},{\"label\":\"absent\",\"value\":0},{\"label\":\"late\",\"value\":0}]}','2026-08-06 20:11:54'),('6263bdd3-2625-4370-b8af-555ff56fdef4','6d89c02e-6f51-426f-bb25-06161c367e76','monthly','2026-08-01','{\"tasksDone\":1,\"completionRate\":100,\"coins\":10,\"dayStreak\":0,\"sleepHours\":0,\"waterGlasses\":0,\"taskChart\":[{\"label\":\"1\",\"value\":0},{\"label\":\"2\",\"value\":0},{\"label\":\"3\",\"value\":0},{\"label\":\"4\",\"value\":0},{\"label\":\"5\",\"value\":0},{\"label\":\"6\",\"value\":1},{\"label\":\"7\",\"value\":0},{\"label\":\"8\",\"value\":0},{\"label\":\"9\",\"value\":0},{\"label\":\"10\",\"value\":0},{\"label\":\"11\",\"value\":0},{\"label\":\"12\",\"value\":0},{\"label\":\"13\",\"value\":0},{\"label\":\"14\",\"value\":0},{\"label\":\"15\",\"value\":0},{\"label\":\"16\",\"value\":0},{\"label\":\"17\",\"value\":0},{\"label\":\"18\",\"value\":0},{\"label\":\"19\",\"value\":0},{\"label\":\"20\",\"value\":0},{\"label\":\"21\",\"value\":0},{\"label\":\"22\",\"value\":0},{\"label\":\"23\",\"value\":0},{\"label\":\"24\",\"value\":0},{\"label\":\"25\",\"value\":0},{\"label\":\"26\",\"value\":0},{\"label\":\"27\",\"value\":0},{\"label\":\"28\",\"value\":0},{\"label\":\"29\",\"value\":0},{\"label\":\"30\",\"value\":0},{\"label\":\"31\",\"value\":0}],\"trendChart\":[{\"label\":\"1\",\"value\":0},{\"label\":\"2\",\"value\":0},{\"label\":\"3\",\"value\":0},{\"label\":\"4\",\"value\":0},{\"label\":\"5\",\"value\":0},{\"label\":\"6\",\"value\":0},{\"label\":\"7\",\"value\":0},{\"label\":\"8\",\"value\":0},{\"label\":\"9\",\"value\":0},{\"label\":\"10\",\"value\":0},{\"label\":\"11\",\"value\":0},{\"label\":\"12\",\"value\":0},{\"label\":\"13\",\"value\":0},{\"label\":\"14\",\"value\":0},{\"label\":\"15\",\"value\":0},{\"label\":\"16\",\"value\":0},{\"label\":\"17\",\"value\":0},{\"label\":\"18\",\"value\":0},{\"label\":\"19\",\"value\":0},{\"label\":\"20\",\"value\":0},{\"label\":\"21\",\"value\":0},{\"label\":\"22\",\"value\":0},{\"label\":\"23\",\"value\":0},{\"label\":\"24\",\"value\":0},{\"label\":\"25\",\"value\":0},{\"label\":\"26\",\"value\":0},{\"label\":\"27\",\"value\":0},{\"label\":\"28\",\"value\":0},{\"label\":\"29\",\"value\":0},{\"label\":\"30\",\"value\":0},{\"label\":\"31\",\"value\":0}],\"categoryChart\":[{\"label\":\"Routine\",\"value\":1}],\"attendance\":[{\"label\":\"present\",\"value\":0},{\"label\":\"absent\",\"value\":0},{\"label\":\"late\",\"value\":0}]}','2026-08-06 20:11:54'),('71c52643-6c97-4209-ad46-a3623efa60c9','4b889e93-d3fd-437b-8af6-85f8dd0f024d','monthly','2026-08-01','{\"tasksDone\":1,\"completionRate\":100,\"coins\":10,\"dayStreak\":0,\"sleepHours\":0,\"waterGlasses\":0,\"taskChart\":[{\"label\":\"1\",\"value\":0},{\"label\":\"2\",\"value\":0},{\"label\":\"3\",\"value\":0},{\"label\":\"4\",\"value\":0},{\"label\":\"5\",\"value\":0},{\"label\":\"6\",\"value\":1},{\"label\":\"7\",\"value\":0},{\"label\":\"8\",\"value\":0},{\"label\":\"9\",\"value\":0},{\"label\":\"10\",\"value\":0},{\"label\":\"11\",\"value\":0},{\"label\":\"12\",\"value\":0},{\"label\":\"13\",\"value\":0},{\"label\":\"14\",\"value\":0},{\"label\":\"15\",\"value\":0},{\"label\":\"16\",\"value\":0},{\"label\":\"17\",\"value\":0},{\"label\":\"18\",\"value\":0},{\"label\":\"19\",\"value\":0},{\"label\":\"20\",\"value\":0},{\"label\":\"21\",\"value\":0},{\"label\":\"22\",\"value\":0},{\"label\":\"23\",\"value\":0},{\"label\":\"24\",\"value\":0},{\"label\":\"25\",\"value\":0},{\"label\":\"26\",\"value\":0},{\"label\":\"27\",\"value\":0},{\"label\":\"28\",\"value\":0},{\"label\":\"29\",\"value\":0},{\"label\":\"30\",\"value\":0},{\"label\":\"31\",\"value\":0}],\"trendChart\":[{\"label\":\"1\",\"value\":0},{\"label\":\"2\",\"value\":0},{\"label\":\"3\",\"value\":0},{\"label\":\"4\",\"value\":0},{\"label\":\"5\",\"value\":0},{\"label\":\"6\",\"value\":0},{\"label\":\"7\",\"value\":0},{\"label\":\"8\",\"value\":0},{\"label\":\"9\",\"value\":0},{\"label\":\"10\",\"value\":0},{\"label\":\"11\",\"value\":0},{\"label\":\"12\",\"value\":0},{\"label\":\"13\",\"value\":0},{\"label\":\"14\",\"value\":0},{\"label\":\"15\",\"value\":0},{\"label\":\"16\",\"value\":0},{\"label\":\"17\",\"value\":0},{\"label\":\"18\",\"value\":0},{\"label\":\"19\",\"value\":0},{\"label\":\"20\",\"value\":0},{\"label\":\"21\",\"value\":0},{\"label\":\"22\",\"value\":0},{\"label\":\"23\",\"value\":0},{\"label\":\"24\",\"value\":0},{\"label\":\"25\",\"value\":0},{\"label\":\"26\",\"value\":0},{\"label\":\"27\",\"value\":0},{\"label\":\"28\",\"value\":0},{\"label\":\"29\",\"value\":0},{\"label\":\"30\",\"value\":0},{\"label\":\"31\",\"value\":0}],\"categoryChart\":[{\"label\":\"Routine\",\"value\":1}],\"attendance\":[{\"label\":\"present\",\"value\":0},{\"label\":\"absent\",\"value\":0},{\"label\":\"late\",\"value\":0}]}','2026-08-06 20:15:16'),('ab44cd74-f553-4226-8eba-cd4fe52d4c67','4b889e93-d3fd-437b-8af6-85f8dd0f024d','weekly','2026-08-03','{\"tasksDone\":1,\"completionRate\":100,\"coins\":10,\"dayStreak\":0,\"sleepHours\":0,\"waterGlasses\":0,\"taskChart\":[{\"label\":\"Mon\",\"value\":0},{\"label\":\"Tue\",\"value\":0},{\"label\":\"Wed\",\"value\":0},{\"label\":\"Thu\",\"value\":1},{\"label\":\"Fri\",\"value\":0},{\"label\":\"Sat\",\"value\":0},{\"label\":\"Sun\",\"value\":0}],\"trendChart\":[{\"label\":\"Mon\",\"value\":0},{\"label\":\"Tue\",\"value\":0},{\"label\":\"Wed\",\"value\":0},{\"label\":\"Thu\",\"value\":0},{\"label\":\"Fri\",\"value\":0},{\"label\":\"Sat\",\"value\":0},{\"label\":\"Sun\",\"value\":0}],\"categoryChart\":[{\"label\":\"Routine\",\"value\":1}],\"attendance\":[{\"label\":\"present\",\"value\":0},{\"label\":\"absent\",\"value\":0},{\"label\":\"late\",\"value\":0}]}','2026-08-06 20:15:16'),('defa0e90-47b0-48c1-af9d-01b0cc693348','88c1fb83-01ef-47db-af95-87f0ec09b873','weekly','2026-08-03','{\"tasksDone\":0,\"completionRate\":0,\"coins\":0,\"dayStreak\":0,\"sleepHours\":0,\"waterGlasses\":0,\"taskChart\":[{\"label\":\"Mon\",\"value\":0},{\"label\":\"Tue\",\"value\":0},{\"label\":\"Wed\",\"value\":0},{\"label\":\"Thu\",\"value\":0},{\"label\":\"Fri\",\"value\":0},{\"label\":\"Sat\",\"value\":0},{\"label\":\"Sun\",\"value\":0}],\"trendChart\":[{\"label\":\"Mon\",\"value\":0},{\"label\":\"Tue\",\"value\":0},{\"label\":\"Wed\",\"value\":0},{\"label\":\"Thu\",\"value\":0},{\"label\":\"Fri\",\"value\":0},{\"label\":\"Sat\",\"value\":0},{\"label\":\"Sun\",\"value\":0}],\"categoryChart\":[],\"attendance\":[{\"label\":\"present\",\"value\":0},{\"label\":\"absent\",\"value\":0},{\"label\":\"late\",\"value\":0}]}','2026-08-07 13:22:39');
/*!40000 ALTER TABLE `reports` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `screen_time`
--

DROP TABLE IF EXISTS `screen_time`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `screen_time` (
  `id` char(36) NOT NULL,
  `child_id` char(36) NOT NULL,
  `date` date NOT NULL,
  `allowed_minutes` smallint(5) unsigned NOT NULL DEFAULT 60,
  `used_minutes` smallint(5) unsigned NOT NULL DEFAULT 0,
  `category` varchar(60) NOT NULL DEFAULT 'Total',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_screen_child_date` (`child_id`,`date`),
  CONSTRAINT `fk_screen_child` FOREIGN KEY (`child_id`) REFERENCES `children` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `screen_time`
--

LOCK TABLES `screen_time` WRITE;
/*!40000 ALTER TABLE `screen_time` DISABLE KEYS */;
INSERT INTO `screen_time` VALUES ('772a0569-26b8-40c8-ab7b-764ca998796d','256ad462-d191-49e2-b671-606fbec688da','2026-08-06',60,35,'Total','2026-08-06 18:21:16','2026-08-06 18:21:16'),('781b485d-4da9-4064-9c39-786ef51c4f8c','256ad462-d191-49e2-b671-606fbec688da','2026-08-03',60,65,'Total','2026-08-06 18:21:16','2026-08-06 18:21:16'),('b4188385-87f8-4405-8323-7ce96348b959','256ad462-d191-49e2-b671-606fbec688da','2026-08-04',60,40,'Total','2026-08-06 18:21:16','2026-08-06 18:21:16'),('c9d0509a-6c3f-4b33-b496-4cf59cf35773','256ad462-d191-49e2-b671-606fbec688da','2026-08-05',60,52,'Total','2026-08-06 18:21:16','2026-08-06 18:21:16');
/*!40000 ALTER TABLE `screen_time` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sleep_records`
--

DROP TABLE IF EXISTS `sleep_records`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sleep_records` (
  `id` char(36) NOT NULL,
  `child_id` char(36) NOT NULL,
  `date` date NOT NULL,
  `bedtime_hour` tinyint(3) unsigned NOT NULL DEFAULT 20,
  `bedtime_minute` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `wake_hour` tinyint(3) unsigned NOT NULL DEFAULT 6,
  `wake_minute` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `hours` decimal(4,1) NOT NULL DEFAULT 0.0,
  `quality` enum('restful','good','fair','poor') NOT NULL DEFAULT 'good',
  `notes` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_sleep_child_date` (`child_id`,`date`),
  CONSTRAINT `fk_sleep_child` FOREIGN KEY (`child_id`) REFERENCES `children` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sleep_records`
--

LOCK TABLES `sleep_records` WRITE;
/*!40000 ALTER TABLE `sleep_records` DISABLE KEYS */;
INSERT INTO `sleep_records` VALUES ('0916250c-2cb0-445d-810f-2ca11534304b','256ad462-d191-49e2-b671-606fbec688da','2026-08-03',21,30,6,30,8.5,'fair','','2026-08-06 18:21:16'),('6ab7b5d6-f1c3-4255-aa55-8472e1e15ac1','256ad462-d191-49e2-b671-606fbec688da','2026-08-05',21,0,6,45,9.0,'good','','2026-08-06 18:21:16'),('86ba6f07-53d3-4e9c-809e-3799a67ccacc','256ad462-d191-49e2-b671-606fbec688da','2026-08-04',20,45,6,15,9.0,'good','','2026-08-06 18:21:16'),('88d58be9-a871-45f4-91eb-71afce828925','256ad462-d191-49e2-b671-606fbec688da','2026-08-02',20,15,6,0,9.0,'good','','2026-08-06 18:21:16'),('9ed0fd1a-f2c9-4ee7-b9ee-8b98d766f009','256ad462-d191-49e2-b671-606fbec688da','2026-08-01',20,45,7,0,9.5,'restful','Weekend sleep-in','2026-08-06 18:21:16'),('b6989f39-ebf7-4949-9e52-348c2d082056','256ad462-d191-49e2-b671-606fbec688da','2026-08-06',20,30,6,30,9.5,'restful','Fell asleep quickly','2026-08-06 18:21:16'),('caa75beb-fa1d-45ef-b7c1-4476133ef521','256ad462-d191-49e2-b671-606fbec688da','2026-07-31',21,15,6,30,8.5,'fair','','2026-08-06 18:21:16');
/*!40000 ALTER TABLE `sleep_records` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `water_glasses`
--

DROP TABLE IF EXISTS `water_glasses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `water_glasses` (
  `id` char(36) NOT NULL,
  `water_intake_id` char(36) NOT NULL,
  `logged_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_water_glasses_intake` (`water_intake_id`),
  CONSTRAINT `fk_water_glasses_intake` FOREIGN KEY (`water_intake_id`) REFERENCES `water_intakes` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `water_glasses`
--

LOCK TABLES `water_glasses` WRITE;
/*!40000 ALTER TABLE `water_glasses` DISABLE KEYS */;
INSERT INTO `water_glasses` VALUES ('110b3bf0-0b10-4989-b7dc-724acbce3453','096331aa-7185-4695-94ca-3b209dfe04c3','2026-08-06 07:50:00'),('367cbabc-4f6d-4b39-81ef-3288400eb2ea','096331aa-7185-4695-94ca-3b209dfe04c3','2026-08-06 15:00:00'),('56f37d4d-d61d-4011-8d6d-ee67ccf78695','096331aa-7185-4695-94ca-3b209dfe04c3','2026-08-06 17:20:00'),('811f5842-4e17-4405-a926-34745562398f','096331aa-7185-4695-94ca-3b209dfe04c3','2026-08-06 09:15:00'),('860af0e3-31a3-4310-a73b-83d1fe522dbe','096331aa-7185-4695-94ca-3b209dfe04c3','2026-08-06 12:30:00'),('af3025d8-eef1-486e-a490-8c1a97b35c30','096331aa-7185-4695-94ca-3b209dfe04c3','2026-08-06 10:40:00');
/*!40000 ALTER TABLE `water_glasses` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `water_intakes`
--

DROP TABLE IF EXISTS `water_intakes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `water_intakes` (
  `id` char(36) NOT NULL,
  `child_id` char(36) NOT NULL,
  `date` date NOT NULL,
  `glasses` smallint(5) unsigned NOT NULL DEFAULT 0,
  `target_glasses` smallint(5) unsigned NOT NULL DEFAULT 8,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_water_child_date` (`child_id`,`date`),
  CONSTRAINT `fk_water_child` FOREIGN KEY (`child_id`) REFERENCES `children` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `water_intakes`
--

LOCK TABLES `water_intakes` WRITE;
/*!40000 ALTER TABLE `water_intakes` DISABLE KEYS */;
INSERT INTO `water_intakes` VALUES ('096331aa-7185-4695-94ca-3b209dfe04c3','256ad462-d191-49e2-b671-606fbec688da','2026-08-06',6,8,'2026-08-06 18:21:16','2026-08-06 18:21:16');
/*!40000 ALTER TABLE `water_intakes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping routines for database 'smart_child_hub'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-08-07 18:41:58
