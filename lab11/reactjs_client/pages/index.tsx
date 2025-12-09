import { useState, useEffect } from 'react';
import axios from 'axios';
import styles from '../styles/Home.module.css';

interface Person {
  id: number;
  name: string;
  born?: number;
}

const API_BASE_URL = 'http://127.0.0.1:8000/api/persons/';

export default function Home() {
  const [persons, setPersons] = useState<Person[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [showForm, setShowForm] = useState(false);
  const [editingPerson, setEditingPerson] = useState<Person | null>(null);
  const [formData, setFormData] = useState({ name: '', born: '' });

  useEffect(() => {
    fetchPersons();
  }, []);

  const fetchPersons = async () => {
    try {
      setLoading(true);
      setError(null);
      const response = await axios.get<Person[]>(API_BASE_URL);
      setPersons(response.data);
    } catch (err: any) {
      let errorMessage = 'Failed to load persons. ';
      if (err.response) {
        errorMessage += `Status: ${err.response.status}`;
      } else if (err.request) {
        errorMessage += 'Cannot connect to API. Make sure Django server is running on http://127.0.0.1:8000';
      } else {
        errorMessage += err.message || 'Unknown error occurred';
      }
      setError(errorMessage);
      console.error('Error details:', err);
    } finally {
      setLoading(false);
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      setError(null);
      const personData = {
        name: formData.name,
        born: formData.born ? parseInt(formData.born) : null,
      };

      if (editingPerson) {
        await axios.patch(`${API_BASE_URL}${editingPerson.id}/`, personData);
      } else {
        await axios.post(API_BASE_URL, personData);
      }

      setShowForm(false);
      setEditingPerson(null);
      setFormData({ name: '', born: '' });
      fetchPersons();
    } catch (err: any) {
      let errorMessage = 'Failed to save person. ';
      if (err.response) {
        // Server responded with error status
        errorMessage += `Status: ${err.response.status}. `;
        if (err.response.data) {
          if (typeof err.response.data === 'string') {
            errorMessage += err.response.data;
          } else if (err.response.data.error) {
            errorMessage += err.response.data.error;
          } else if (err.response.data.name) {
            errorMessage += err.response.data.name[0];
          }
        }
      } else if (err.request) {
        // Request was made but no response
        errorMessage += 'Cannot connect to API. Make sure Django server is running on http://127.0.0.1:8000';
      } else {
        errorMessage += err.message || 'Unknown error occurred';
      }
      setError(errorMessage);
      console.error('Error details:', err);
    }
  };

  const handleEdit = (person: Person) => {
    setEditingPerson(person);
    setFormData({
      name: person.name,
      born: person.born?.toString() || '',
    });
    setShowForm(true);
  };

  const handleDelete = async (id: number) => {
    if (!confirm('Are you sure you want to delete this person?')) {
      return;
    }

    try {
      await axios.delete(`${API_BASE_URL}${id}/`);
      fetchPersons();
    } catch (err) {
      setError('Failed to delete person');
      console.error(err);
    }
  };

  const handleCancel = () => {
    setShowForm(false);
    setEditingPerson(null);
    setFormData({ name: '', born: '' });
  };

  return (
    <div className={styles.container}>
      <main className={styles.main}>
        <h1 className={styles.title}>Person CRUD Application</h1>

        <div className={styles.controls}>
          <button
            className={styles.addButton}
            onClick={() => {
              setShowForm(true);
              setEditingPerson(null);
              setFormData({ name: '', born: '' });
            }}
          >
            Add New Person
          </button>
          <button className={styles.refreshButton} onClick={fetchPersons}>
            Refresh
          </button>
        </div>

        {error && <div className={styles.error}>{error}</div>}

        {showForm && (
          <div className={styles.modal}>
            <div className={styles.modalContent}>
              <h2>{editingPerson ? 'Edit Person' : 'Add New Person'}</h2>
              <form onSubmit={handleSubmit}>
                <div className={styles.formGroup}>
                  <label htmlFor="name">Name:</label>
                  <input
                    type="text"
                    id="name"
                    value={formData.name}
                    onChange={(e) =>
                      setFormData({ ...formData, name: e.target.value })
                    }
                    required
                  />
                </div>
                <div className={styles.formGroup}>
                  <label htmlFor="born">Born (Year):</label>
                  <input
                    type="number"
                    id="born"
                    value={formData.born}
                    onChange={(e) =>
                      setFormData({ ...formData, born: e.target.value })
                    }
                  />
                </div>
                <div className={styles.formActions}>
                  <button type="submit" className={styles.saveButton}>
                    {editingPerson ? 'Update' : 'Create'}
                  </button>
                  <button
                    type="button"
                    onClick={handleCancel}
                    className={styles.cancelButton}
                  >
                    Cancel
                  </button>
                </div>
              </form>
            </div>
          </div>
        )}

        {loading ? (
          <div className={styles.loading}>Loading...</div>
        ) : (
          <div className={styles.personList}>
            {persons.length === 0 ? (
              <p className={styles.empty}>No persons found</p>
            ) : (
              persons.map((person) => (
                <div key={person.id} className={styles.personCard}>
                  <div className={styles.personInfo}>
                    <h3>{person.name}</h3>
                    <p>
                      {person.born
                        ? `Born: ${person.born}`
                        : 'Born: Not specified'}
                    </p>
                  </div>
                  <div className={styles.personActions}>
                    <button
                      className={styles.editButton}
                      onClick={() => handleEdit(person)}
                    >
                      Edit
                    </button>
                    <button
                      className={styles.deleteButton}
                      onClick={() => handleDelete(person.id)}
                    >
                      Delete
                    </button>
                  </div>
                </div>
              ))
            )}
          </div>
        )}
      </main>
    </div>
  );
}

