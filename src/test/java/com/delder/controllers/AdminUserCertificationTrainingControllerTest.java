package com.delder.controllers;

import static org.assertj.core.api.Java6Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.multipart;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.io.File;
import java.io.FileInputStream;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.List;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.junit.runner.RunWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Captor;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.Configuration;
import org.springframework.mock.web.MockMultipartFile;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.result.MockMvcResultHandlers;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;

import com.delder.entities.CertificationTraining;
import com.delder.entities.PrimeUser;
import com.delder.entities.UserCertTraining;
import com.delder.repositories.UserCertTrainingRepository;
import com.delder.services.UserCertTrainingService;
import com.delder.services.UserService;

@ExtendWith(MockitoExtension.class)
@RunWith(SpringJUnit4ClassRunner.class) // TODO - need to figure out how to use @SpringJUnitWebConfig
@ContextConfiguration(locations = "classpath:spring/mvc-test-config.xml")
class AdminUserCertificationTrainingControllerTest {

	public static final long TEST_ID = 1L;
	public static final int TEST_VERSION = 111;
	public static final int EXPIRATION_DAYS = 2;
	public static final int EXPIRATION_MONTHS = 60;
	public static final String CLASS_NAME = "Unit Testing with JUnit and Mockito";
	public static final String CLASS_NUMBER = "101-UNIT-TEST";

	@Configuration
	@ComponentScan("com.delder.security.bean")
	static class Config {

	}

	@Mock
	UserService userService;

	@Mock
	UserCertTrainingService userCertTrainingService;

	@Mock
	UserCertTrainingRepository userCertTrainingRepository;

	@Mock
	AdminUserCertificationTrainingController adminUserCertificationTrainingController;

	List<UserCertTraining> userCertTrainingList = new ArrayList<>();

	MockMvc mockMvc;

	@Captor
	ArgumentCaptor<String> stringArgumentCaptor;

	@Test
	void checkVariables() {
		// assertTrue(userService != null);
	}

	private void createTestList() {
		PrimeUser primeUser = new PrimeUser();
		primeUser.setId(AdminUserCertificationTrainingControllerTest.TEST_ID);
		CertificationTraining certificationTraining = new CertificationTraining();
		certificationTraining.setId(AdminUserCertificationTrainingControllerTest.TEST_ID);
		certificationTraining.setClassNumber(AdminUserCertificationTrainingControllerTest.CLASS_NUMBER);
		certificationTraining.setClassName(AdminUserCertificationTrainingControllerTest.CLASS_NAME);
		certificationTraining.setExpirationInDays(AdminUserCertificationTrainingControllerTest.EXPIRATION_MONTHS);
		certificationTraining.setExpirationInMonths(AdminUserCertificationTrainingControllerTest.EXPIRATION_DAYS);
		certificationTraining.setVersion(AdminUserCertificationTrainingControllerTest.TEST_VERSION);
		UserCertTraining userCertTraining = new UserCertTraining();
		userCertTraining.setId(AdminUserCertificationTrainingControllerTest.TEST_ID);
		userCertTraining.setCertificationTrainingId(AdminUserCertificationTrainingControllerTest.TEST_ID);
		userCertTraining.setCertificationTraining(certificationTraining);
		userCertTraining.setPrimeUserId(AdminUserCertificationTrainingControllerTest.TEST_ID);
		userCertTraining.setPrimeUser(primeUser);
		userCertTrainingList.add(userCertTraining);
	}

	@BeforeEach
	void setUp() throws Exception {
		assertThat(mockMvc).isNull();
		mockMvc = MockMvcBuilders.standaloneSetup(adminUserCertificationTrainingController)
				.alwaysDo(MockMvcResultHandlers.print()).build();
		userCertTrainingService = new UserCertTrainingService();
	}

	@Test
	@DisplayName("showUserCertTraining")
	void testShowUserCertTraining() throws Exception { // when ModelAndView modelAndView =
		// TODO figure out how to wire up the view resolver for primeR
		mockMvc.perform(get("/userCertTraining")).andExpect(status().is(404));
	}

	@Test
	@DisplayName("getData")
	void testGetData() throws Exception {
		mockMvc.perform(get("/loadDataAJax")).andExpect(status().is(404));
	}

	@Test
	@DisplayName("newUserCertTrainingAjax")
	void testNewUserCertTrainingAjax() throws Exception {
		mockMvc.perform(get("/newUserCertTrainingAjax")).andExpect(status().is(404));
	}

	@Test
	@DisplayName("deleteUserCertTrainingAjax")
	void testDeleteUserCertTrainingAjax() throws Exception {
		mockMvc.perform(get("/deleteUserCertTrainingAjax")).andExpect(status().is(404));
	}

	@Test
	@DisplayName("importUserCertTraining")
	void testImportUserCertTraining() throws Exception {
		String path = "src/test/resources/usercerttraining.xlsx";
		File excel = new File(path);
		String absolutePath = excel.getAbsolutePath();
		assertThat(absolutePath).isNotNull();
		InputStream stream = new FileInputStream(excel);
		assertThat(stream).isNotNull(); // fire") MultipPart
		// filenamest arg to constructor must match RequestParam("filenam
		MockMultipartFile file = new MockMultipartFile("filename", "usercerttraining.xlsx", "application/vnd.ms-excel",
				stream);
		mockMvc.perform(multipart("/importCertUserTraining").file(file)).andExpect(status().is(404));
	}

}
