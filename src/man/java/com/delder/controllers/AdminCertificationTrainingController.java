package com.delder.controllers;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;

import org.apache.logging.log4j.Logger;
import org.springframework.beans.BeanUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.ModelAndView;

import com.delder.constants.ApplicationConstants;
import com.delder.entities.CertificationTraining;
import com.delder.entities.ProgramCertificationTraining;
import com.delder.excel.CertificationTrainingExcel;
import com.delder.exceptions.PrimeException;
import com.delder.forms.CertificationTrainingForm;
import com.delder.repositories.ProgramCertificationTrainingRepository;
import com.delder.responses.DatatablesResponse;
import com.delder.services.CertificationTrainingService;
import com.delder.services.ProgramCertificationTrainingService;
import com.delder.services.ProgramService;
import com.delder.utilities.ExcelUtility;
import com.delder.utilities.ProgramsUtility;

@Controller
@RequestMapping("/{programName}/admin/certificationtraining/*")
public class AdminCertificationTrainingController extends BaseController {

	protected static transient final Logger log = org.apache.logging.log4j.LogManager
			.getLogger(AdminCertificationTrainingController.class);

	@Autowired
	private CertificationTrainingService certificationtrainingService;

	@Autowired
	private ProgramCertificationTrainingRepository programCertificationtrainingRepository;

	@Autowired
	private ProgramCertificationTrainingService programCertificationtrainingService;

	@Autowired
	private ProgramService programService;

	@PreAuthorize("{@methodAccessBean.getPermision('ADMIN_CERT_TRAINING')}")
	@RequestMapping(value = "certificationtraining", method = { RequestMethod.GET, RequestMethod.POST })
	public ModelAndView showCertificationTraining(HttpServletRequest request) throws Exception {
		Map<String, Object> model = new HashMap<String, Object>();
		return new ModelAndView("admin.certificationtraining", model);
	}

	@PreAuthorize("{@methodAccessBean.getPermision('ADMIN_CERT_TRAINING')}")
	@RequestMapping(value = "loadDataAjax", method = { RequestMethod.GET, RequestMethod.POST })
	public @ResponseBody DatatablesResponse getData(HttpServletRequest request) throws Exception {
		Long programId = ProgramsUtility.activeProgramId(request);
		List<CertificationTraining> certTrainings = programCertificationtrainingRepository
				.findAllByProgramIdOrderByClassNameAsc(programId);

		List<Object> rows = new ArrayList<Object>();
		for (CertificationTraining certTraining : certTrainings) {
			Map<String, Object> row = new HashMap<String, Object>();
			row.put("id", certTraining.getId());
			row.put("version", certTraining.getVersion());
			row.put("className", certTraining.getClassName());
			row.put("classNumber", certTraining.getClassNumber());
			row.put("expirationInDays", certTraining.getExpirationInDays());
			row.put("expirationInMonths", certTraining.getExpirationInMonths());
			rows.add(row);
		}
		return new DatatablesResponse(rows);
	}

	@PreAuthorize("{@methodAccessBean.getPermision('ADMIN_CERT_TRAINING_ADD_MOD_DEL')}")
	@RequestMapping(value = "newCertificationTrainingAjax", method = RequestMethod.POST)
	public ResponseEntity<String> newCertificationTrainingAjax(HttpServletRequest request,
			@ModelAttribute CertificationTrainingForm certificationtrainingForm) throws Exception {
		try {
			Long programId = ProgramsUtility.activeProgramId(request);
			CertificationTraining certificationTraining = new CertificationTraining();
			ProgramCertificationTraining programCertificationTraining = new ProgramCertificationTraining();
			programCertificationTraining.setProgramId(programId);
			programCertificationTraining.setProgram(programService.getProgram(programId));
			BeanUtils.copyProperties(certificationtrainingForm, certificationTraining);
			programCertificationTraining.setCertificationTraining(certificationTraining);
			programCertificationtrainingService.createProgramCertificationTraining(programCertificationTraining);

			return new ResponseEntity<String>("success", HttpStatus.OK);
		} catch (PrimeException e) {
			log.info("Error creating new certificationtraining. " + e.getMessage());
			return new ResponseEntity<String>("Error creating new Certification Training: " + e.getMessage(),
					HttpStatus.OK);
		} catch (Exception e) {
			log.error("Error creating new certificationtraining. " + e.getMessage(), e);
			return new ResponseEntity<String>(
					ApplicationConstants.SERVER_ERROR + " cannot save new Certification Training", HttpStatus.OK);
		}
	}

	@PreAuthorize("{@methodAccessBean.getPermision('ADMIN_CERT_TRAINING_ADD_MOD_DEL')}")
	@RequestMapping(value = "modifyCertificationTrainingAjax", method = RequestMethod.POST)
	public ResponseEntity<String> modifyCertificationTrainingAjax(HttpServletRequest request,
			@ModelAttribute CertificationTrainingForm certificationtrainingForm) throws Exception {
		try {
			CertificationTraining certificationTraining = new CertificationTraining();
			BeanUtils.copyProperties(certificationtrainingForm, certificationTraining);

			certificationtrainingService.saveModified(certificationTraining);

			return new ResponseEntity<String>("success", HttpStatus.OK);
		} catch (PrimeException e) {
			log.info("Error modifying certificationtraining: " + e.getMessage());
			return new ResponseEntity<String>("Error modifying Certification Training: " + e.getMessage(),
					HttpStatus.OK);
		} catch (Exception e) {
			log.error("Error modifying certificationtraining: " + e.getMessage(), e);
			return new ResponseEntity<String>(
					ApplicationConstants.SERVER_ERROR + " cannot modify Certification Training", HttpStatus.OK);
		}
	}

	@PreAuthorize("{@methodAccessBean.getPermision('ADMIN_CERT_TRAINING_ADD_MOD_DEL')}")
	@RequestMapping(value = "deleteCertificationTrainingAjax", method = RequestMethod.POST)
	public ResponseEntity<String> deleteCertificationTrainingAjax(HttpServletRequest request,
			@ModelAttribute CertificationTrainingForm certificationtrainingForm) throws Exception {
		try {
			Long programId = ProgramsUtility.activeProgramId(request);
			ProgramCertificationTraining programCertificationTraining = programCertificationtrainingRepository
					.findByClassNumberAndProgramId(certificationtrainingForm.getClassNumber(), programId);
			programCertificationtrainingRepository.deleteById(programCertificationTraining.getId());
			certificationtrainingService.deleteCertificationTraining(certificationtrainingForm.getId(),
					certificationtrainingForm.getVersion());
			return new ResponseEntity<String>("success", HttpStatus.OK);
		} catch (PrimeException e) {
			log.info("Error deleting certificationtraining: " + e.getMessage());
			return new ResponseEntity<String>("Error deleting Certification Training: " + e.getMessage(),
					HttpStatus.OK);
		} catch (Exception e) {
			log.error("Error deleting certificationtraining: " + e.getMessage(), e);
			return new ResponseEntity<String>(
					ApplicationConstants.SERVER_ERROR + " cannot delete Certification Training", HttpStatus.OK);
		}
	}

	@PreAuthorize("{@methodAccessBean.getPermision('ADMIN_CERT_TRAINING_ADD_MOD_DEL')}")
	@RequestMapping(value = "importCertificationTraining", method = RequestMethod.POST)
	public ResponseEntity<String> importCertificationTraining(HttpServletRequest request,
			@RequestParam("filename") MultipartFile fileName) throws Exception {
		try {
			Long programId = ProgramsUtility.activeProgramId(request);
			List<CertificationTrainingExcel> certificationtrainingExcelRows = ExcelUtility.readExcel(fileName,
					CertificationTrainingExcel.class);
			ProgramCertificationTraining programCertificationtraining;
			for (CertificationTrainingExcel certificationTrainingExcel : certificationtrainingExcelRows) {
				programCertificationtraining = certificationTrainingExcel.newProgramCertificationTraining(programId);
				programCertificationtraining.setProgram(programService.getProgram(programId));
				programCertificationtrainingService.createProgramCertificationTraining(programCertificationtraining);
			}
			return new ResponseEntity<String>("success", HttpStatus.OK);
		} catch (PrimeException e) {
			log.info("importCertificationTraining - " + e.getMessage());
			return new ResponseEntity<String>("Cannot upload Certification Trainings - " + e.getMessage(),
					HttpStatus.OK);
		} catch (Exception e) {
			log.error("importCertificationTraining - " + e.getMessage(), e);
			return new ResponseEntity<String>("Cannot upload Certification Trainings", HttpStatus.OK);
		}
	}

}
