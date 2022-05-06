package com.delder.services;

import static org.assertj.core.api.Assertions.assertThat;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertThrows;
import static org.junit.Assert.assertTrue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.BDDMockito.given;
import static org.mockito.BDDMockito.then;
import static org.mockito.Mockito.atLeastOnce;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import com.delder.entities.CertificationTraining;
import com.delder.entities.PrimeUser;
import com.delder.entities.UserCertTraining;
import com.delder.exceptions.PrimeException;
import com.delder.repositories.UserCertTrainingRepository;

@ExtendWith(MockitoExtension.class)
class UserCertTrainingServiceTest {

	static final String bemsId = "3391152";
	static final String lastName = "Gregorgen, Matthew G";
	static final String firstName = "Matthew";
	static final String middleInitial = "G";
	static final String classNumber = "JUnit-101";
	static final String className = "Unit Testing with JUnit and Mockito";
	static final Long id = 1L;
	static final Integer version = 1;

	@Mock
	UserCertTrainingRepository userCertTrainingRepository;

	@InjectMocks
	UserCertTrainingService userCertTrainingService;

	private PrimeUser goodPrimeUser() {
		PrimeUser primeUser = new PrimeUser();
		primeUser.setId(id);
		primeUser.setBemsId(bemsId);
		primeUser.setLastName(lastName);
		primeUser.setFirstName(firstName);
		primeUser.setMiddleInitial(middleInitial);
		return primeUser;
	}

	private CertificationTraining goodCertificationTrainng() {
		CertificationTraining certificationTraining = new CertificationTraining();
		certificationTraining.setId(id);
		certificationTraining.setClassNumber(classNumber);
		certificationTraining.setClassName(className);
		return certificationTraining;
	}

	private UserCertTraining goodUserCertTraining() {
		UserCertTraining userCertTraining = new UserCertTraining();
		userCertTraining.setId(id);
		PrimeUser primeUser = goodPrimeUser();
		CertificationTraining certificationTraining = goodCertificationTrainng();
		userCertTraining.setPrimeUserId(primeUser.getId());
		userCertTraining.setPrimeUser(primeUser);
		userCertTraining.setCertificationTrainingId(certificationTraining.getId());
		userCertTraining.setCertificationTraining(certificationTraining);
		return userCertTraining;
	}

	private UserCertTraining userCertTrainingBadPrimeUser() {
		UserCertTraining userCertTraining = new UserCertTraining();
		userCertTraining.setId(id);
		CertificationTraining certificationTraining = goodCertificationTrainng();
		userCertTraining.setCertificationTrainingId(certificationTraining.getId());
		userCertTraining.setCertificationTraining(certificationTraining);
		userCertTraining.setPrimeUser(new PrimeUser());
		return userCertTraining;
	}

	private UserCertTraining userCertTrainingNullPrimeUser() {
		UserCertTraining userCertTraining = new UserCertTraining();
		userCertTraining.setId(id);
		CertificationTraining certificationTraining = goodCertificationTrainng();
		userCertTraining.setCertificationTrainingId(certificationTraining.getId());
		userCertTraining.setCertificationTraining(certificationTraining);
		userCertTraining.setPrimeUser(null);
		return userCertTraining;
	}

	@Test
	@DisplayName("userCertTrainingCertificationTrainingExists")
	void userCertTrainingExists() {
		UserCertTraining userCertTraining = new UserCertTraining();
		boolean result = userCertTrainingService.userCertTrainingExists(userCertTraining);
		assertFalse(result);
	}

	@Test
	@DisplayName("UserCertTraining: CertificationTraining is Null")
	void certerificationIsNull() throws PrimeException {
		Exception expectedEx = assertThrows(PrimeException.class, () -> {
			userCertTrainingService.saveNew(new UserCertTraining());
		});
		assertTrue(expectedEx.getMessage().startsWith("UserCertTraining must hava a Certification Training set"));
	}

	@Test
	@DisplayName("UserCertTraining: CertificationTrainingId is Null")
	void certerificationTrainingIdIsNull() throws PrimeException {
		// given
		UserCertTraining userCertTraining = new UserCertTraining();
		userCertTraining.setCertificationTraining(new CertificationTraining());
		Exception expectedEx = assertThrows(PrimeException.class, () -> {
			userCertTrainingService.saveNew(userCertTraining);
		});
		assertTrue(expectedEx.getMessage().startsWith("UserCertTraining must hava a Certification Training Id set"));
	}

	@Test
	@DisplayName("UserCertTraining: PrimeUser is Null")
	void userCerTrainingPrimeUserIsNull() throws PrimeException {
		// given
		UserCertTraining userCertTraining = new UserCertTraining();
		userCertTraining.setCertificationTraining(new CertificationTraining());
		userCertTraining.setCertificationTrainingId(id);
		Exception expectedEx = assertThrows(PrimeException.class, () -> {
			userCertTrainingService.saveNew(userCertTraining);
		});
		assertTrue(expectedEx.getMessage().startsWith("UserCertTraining must hava a PrimeUser set"));
	}

	@Test
	@DisplayName("UserCertTraining: PrimeUserId is Null")
	void primeUserIdIsNull() throws PrimeException {
		Exception expectedEx = assertThrows(PrimeException.class, () -> {
			userCertTrainingService.saveNew(userCertTrainingBadPrimeUser());
		});
		assertTrue(expectedEx.getMessage().startsWith("UserCertTraining must hava a Prime User Id set"));
	}

	@Test
	@DisplayName("primeUser Is Null")
	void primeUserIsNull() throws PrimeException {
		Exception expectedEx = assertThrows(PrimeException.class, () -> {
			userCertTrainingService.saveNew(userCertTrainingNullPrimeUser());
		});
		assertTrue(expectedEx.getMessage().startsWith("UserCertTraining must hava a PrimeUser set"));
	}

	List<UserCertTraining> userCertTrainingList;

	@Test
	@DisplayName("findAllOrderByBemsIdAsc with BDD testing")
	void findAllOrderByBemsIdAscBDD() {
		// given
		userCertTrainingList = new ArrayList<>();
		userCertTrainingList.add(new UserCertTraining());
		given(userCertTrainingRepository.findAllOrderByBemsIdAsc()).willReturn(userCertTrainingList);
		// when
		List<UserCertTraining> userCertTrainingList = userCertTrainingRepository.findAllOrderByBemsIdAsc();
		// then
		assertThat(userCertTrainingList).isNotNull();
		assertThat(userCertTrainingList).hasSize(1);
		then(userCertTrainingRepository).should(times(1)).findAllOrderByBemsIdAsc();
		then(userCertTrainingRepository).shouldHaveNoMoreInteractions();
	}

	private UserCertTraining makeUserCertTraining() {
		UserCertTraining userCertTraining = new UserCertTraining();
		userCertTraining.setId(id);
		userCertTraining.setVersion(version);
		userCertTraining.setPrimeUser(new PrimeUser());
		userCertTraining.setPrimeUserId(id);
		userCertTraining.getPrimeUser().setId(id);
		userCertTraining.getPrimeUser().setBemsId(bemsId);
		userCertTraining.setCertificationTraining(new CertificationTraining());
		userCertTraining.setCertificationTrainingId(id);
		userCertTraining.getCertificationTraining().setId(id);
		userCertTraining.getCertificationTraining().setClassNumber(classNumber);
		return userCertTraining;
	}

	@Test
	void findById() {
		UserCertTraining userCertTraining = new UserCertTraining();
		when(userCertTrainingRepository.findById(anyLong())).thenReturn(Optional.of(userCertTraining));
		Optional<UserCertTraining> foundUserCertTraining = userCertTrainingRepository.findById(id);
		verify(userCertTrainingRepository).findById(anyLong());
		assertThat(foundUserCertTraining).isNotNull();

	}

	@Test
	void save() {
		UserCertTraining userCertTraining = new UserCertTraining();
		when(userCertTrainingRepository.save(any(UserCertTraining.class))).thenReturn(userCertTraining);
		UserCertTraining savedUserCertTraining = userCertTrainingRepository.save(new UserCertTraining());
		verify(userCertTrainingRepository).save(any(UserCertTraining.class));
		assertThat(savedUserCertTraining).isNotNull();
	}

	@Test
	void delete() {
		UserCertTraining userCertTraining = new UserCertTraining();
		userCertTrainingRepository.delete(userCertTraining);
		verify(userCertTrainingRepository).delete(any(UserCertTraining.class));
	}

	@Test
	void deleteById() {
		// when
		userCertTrainingRepository.deleteById(id);
		// then
		verify(userCertTrainingRepository).deleteById(anyLong());
	}

	@Test
	@DisplayName("testDelete using BDD")
	void testDelete() {
		// when
		userCertTrainingRepository.deleteById(id);
		// then
		then(userCertTrainingRepository).should().deleteById(any());
	}

	@Test
	void deleteByIdNever() {
		// when
		userCertTrainingRepository.deleteById(id);
		// then
		then(userCertTrainingRepository).should(atLeastOnce()).deleteById(id);
		then(userCertTrainingRepository).should(never()).deleteById(5L);
	}

	@Test
	@DisplayName("findByBemsIdAndClassNumber")
	void findByBemsIdAndClassNumber() {
		// given
		UserCertTraining userCertTraining = makeUserCertTraining();
		given(userCertTrainingRepository.findByBemsIdAndClassNumber(bemsId, classNumber)).willReturn(userCertTraining);

		// when
		UserCertTraining foundUserCertTraining = userCertTrainingRepository.findByBemsIdAndClassNumber(bemsId,
				classNumber);

		// then
		assertTrue(foundUserCertTraining.getPrimeUser().getBemsId().equals(bemsId)
				&& foundUserCertTraining.getCertificationTraining().getClassNumber().equals(classNumber));
		verify(userCertTrainingRepository).findByBemsIdAndClassNumber(anyString(), anyString());
	}

	@Test
	@DisplayName("findByBemsIdAndClassNumber")
	void findAllOrderByBemsIdAsc() {
		UserCertTraining userCertTraining = makeUserCertTraining();
		List<UserCertTraining> userCertTrainingList = new ArrayList<UserCertTraining>();
		userCertTrainingList.add(userCertTraining);

		when(userCertTrainingRepository.findAllOrderByBemsIdAsc()).thenReturn(userCertTrainingList);

		List<UserCertTraining> result = userCertTrainingRepository.findAllOrderByBemsIdAsc();
		verify(userCertTrainingRepository).findAllOrderByBemsIdAsc();
		assertThat(result).hasSize(1);
	}

	@Test
	@DisplayName("UserCertTraining does not exist")
	void userCertTrainingDoesNotExist() throws PrimeException {
		assertFalse(userCertTrainingService.userCertTrainingExists(makeUserCertTraining()));
	}

	@Test
	@DisplayName("Delete UserCertTraining that does not exist")
	void deleteUserCertTrainingNotExist() throws PrimeException {
		Exception expectedEx = assertThrows(PrimeException.class, () -> {
			// Does not exist so - throws exception
			userCertTrainingService.deleteUserCertTraining(id, version);
		});
		assertTrue(expectedEx.getMessage().startsWith("User Cert Training does not exist"));
	}

	@Test
	@DisplayName("Delete UserCertTraining with Bad Id")
	void deleteUserCertTrainingBadId() throws PrimeException {
		Exception expectedEx = assertThrows(PrimeException.class, () -> {
			// Does not exist so - throws exception
			userCertTrainingService.deleteUserCertTraining(null, version);
		});
		assertTrue(expectedEx.getMessage().startsWith("Must supply valid User Cert Training ID"));
	}

	@Test
	@DisplayName("Delete UserCertTraining has changed i.e. different version")
	void deleteUserCertTrainingDiffVer() throws PrimeException {
		UserCertTraining userCertTraining = makeUserCertTraining();

		when(userCertTrainingRepository.findById(id)).thenReturn(Optional.of(userCertTraining));
		Exception expectedEx = assertThrows(PrimeException.class, () -> {
			// Does not exist so - throws exception
			userCertTrainingService.deleteUserCertTraining(id, version + 1);
		});
		assertTrue(expectedEx.getMessage().startsWith("User Cert Training has changed"));

	}

	@Test
	@DisplayName("Delete UserCertTraining")
	void deleteUserCertTraining() throws PrimeException {
		UserCertTraining userCertTraining = makeUserCertTraining();

		when(userCertTrainingRepository.findById(id)).thenReturn(Optional.of(userCertTraining));
		userCertTrainingService.deleteUserCertTraining(id, version);
	}

	@Test
	@DisplayName("Does UserCertTraining Exist")
	void doesUserCertTrainingExist() throws PrimeException {
		UserCertTraining userCertTraining = makeUserCertTraining();

		when(userCertTrainingRepository.findByBemsIdAndClassNumber(bemsId, classNumber)).thenReturn(userCertTraining);
		assertTrue(userCertTrainingService.userCertTrainingExists(userCertTraining));

	}

	@DisplayName("Save Modified UserCertTraining")
	void saveModifiedCertTrainingExist() throws PrimeException {
		UserCertTraining userCertTraining = makeUserCertTraining();
		userCertTraining.getCertificationTraining().setClassName("Unit Testing with JUnit and Mockito");
		when(userCertTrainingRepository.findByBemsIdAndClassNumber(bemsId, classNumber)).thenReturn(userCertTraining);
		assertTrue(userCertTrainingService.saveModified(userCertTraining) != null);

	}

}
